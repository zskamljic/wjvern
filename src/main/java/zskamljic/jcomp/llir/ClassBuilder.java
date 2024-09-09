package zskamljic.jcomp.llir;

import zskamljic.jcomp.Blacklist;
import zskamljic.jcomp.StdLibResolver;
import zskamljic.jcomp.llir.models.AggregateType;
import zskamljic.jcomp.llir.models.FunctionRegistry;
import zskamljic.jcomp.llir.models.LlvmType;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.CompoundElement;
import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.MemberRefEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.classfile.constantpool.StringEntry;
import java.lang.classfile.instruction.InvokeInstruction;
import java.lang.classfile.instruction.ThrowInstruction;
import java.lang.constant.ClassDesc;
import java.lang.reflect.AccessFlag;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class ClassBuilder {
    private final ClassModel classModel;
    private final Path classPath;
    private final boolean debug;
    private final StdLibResolver resolver;

    public ClassBuilder(StdLibResolver resolver, ClassModel classModel, Path classPath, boolean debug) {
        this.resolver = resolver;
        this.debug = debug;
        this.classModel = classModel;
        this.classPath = classPath;
    }

    public Map<String, IrClassGenerator> generate() throws IOException {
        var generated = new HashMap<String, IrClassGenerator>();
        var functionRegistry = generateFunctionRegistry();
        var globalInitializer = new GlobalInitializer();
        generate(generated, functionRegistry, globalInitializer);

        globalInitializer.generateEntryPoint(classModel.thisClass().name().stringValue(), generated, c -> generateType(c, generated), functionRegistry);

        return generated;
    }

    private FunctionRegistry generateFunctionRegistry() throws IOException {
        var registry = new FunctionRegistry(this::loadClass, Blacklist::isUnsupportedFunction);
        registry.walk(classModel);

        // TODO: when toString is enabled this will no longer be needed
        var stringClass = loadClass("java/lang/String").orElseThrow();
        registry.walk(stringClass);

        return registry;
    }

    public void generate(
        Map<String, IrClassGenerator> generatedClasses,
        FunctionRegistry functionRegistry,
        GlobalInitializer globalInitializer
    ) throws IOException {
        var className = classModel.thisClass().name().stringValue();
        var classGenerator = new IrClassGenerator(className, debug, c -> generateType(c, generatedClasses), functionRegistry);

        var thrownExceptions = new ArrayList<String>();
        generatedClasses.put(className, classGenerator);
        if (classModel.superclass().isPresent()) {
            var superclass = classModel.superclass().get();
            generateSuperClass(superclass, classGenerator, generatedClasses, functionRegistry, globalInitializer);
            Optional.ofNullable(generatedClasses.get(superclass.name().stringValue()))
                .flatMap(IrClassGenerator::getExceptionDefinition)
                .ifPresent(thrownExceptions::add);
        }
        var staticInvokes = classModel.methods()
            .stream()
            .map(MethodModel::code)
            .flatMap(Optional::stream)
            .flatMap(CompoundElement::elementStream)
            .filter(InvokeInstruction.class::isInstance)
            .map(InvokeInstruction.class::cast)
            .filter(i -> i.opcode() == Opcode.INVOKESTATIC)
            .map(InvokeInstruction::method)
            .toList();

        for (var entry : classModel.constantPool()) {
            switch (entry) {
                case ClassEntry classEntry ->
                    handleClassEntry(classEntry, generatedClasses, functionRegistry, classGenerator, thrownExceptions, globalInitializer);
                case MethodRefEntry method -> handleMethodEntry(method, classGenerator, staticInvokes);
                case StringEntry string -> handleStringEntry(string, classGenerator, globalInitializer);
                default -> {
                    // No need to do anything
                }
            }
        }

        globalInitializer.finishInitialization(classGenerator);

        for (var field : classModel.fields()) {
            var type = IrTypeMapper.mapType(field.fieldTypeSymbol());
            if (type.isReferenceType()) {
                type = new LlvmType.Pointer(type);
            }

            if (field.flags().has(AccessFlag.STATIC)) {
                classGenerator.addStaticField(Utils.staticVariableName(field), type);
            } else {
                classGenerator.addField(field.fieldName().stringValue(), type);
            }
        }

        var hasThrow = false;
        for (var method : classModel.methods()) {
            if (Blacklist.isUnsupportedFunction(method)) {
                continue;
            }
            hasThrow = hasThrow || method.code()
                .stream()
                .flatMap(CompoundElement::elementStream)
                .anyMatch(c -> c instanceof ThrowInstruction);
            classGenerator.addMethod(method);
        }

        classGenerator.injectCode("""
            %"java/util/stream/IntStream" = type opaque
            %"java/util/function/BiFunction" = type opaque
            declare i32 @__gxx_personality_v0(...)
            declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
            declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
            declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
            declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)""");
        if (hasThrow) {
            classGenerator.injectCode("declare i32 @llvm.eh.typeid.for(ptr)");
            classGenerator.injectCode("declare ptr @__cxa_allocate_exception(i64)");
            classGenerator.injectCode("declare void @__cxa_throw(ptr, ptr, ptr)");
            classGenerator.injectCode("declare ptr @__cxa_begin_catch(ptr)");
            classGenerator.injectCode("declare void @__cxa_end_catch()");

            classGenerator.injectCode("""
                @_ZTVN10__cxxabiv117__class_type_infoE = external global ptr
                @_ZTVN10__cxxabiv119__pointer_type_infoE = external global ptr""");

            thrownExceptions.forEach(classGenerator::injectCode);
        }

        // TODO: when toString is enabled this will no longer be needed
        var stringClass = loadClass("java/lang/String").orElseThrow();
        handleClassEntry(stringClass.thisClass(), generatedClasses, functionRegistry, classGenerator, thrownExceptions, globalInitializer);
    }

    private void handleClassEntry(
        ClassEntry classEntry,
        Map<String, IrClassGenerator> generatedClasses,
        FunctionRegistry functionRegistry,
        IrClassGenerator classGenerator,
        List<String> thrownExceptions,
        GlobalInitializer globalInitializer
    ) throws IOException {
        generateClass(classEntry, generatedClasses, functionRegistry, globalInitializer);
        var dependent = Utils.unwrapType(classEntry);
        if (!dependent.isPrimitive()) {
            classGenerator.addRequiredType(new LlvmType.Declared(typeName(dependent)));
        }
        Optional.ofNullable(generatedClasses.get(classEntry.name().stringValue()))
            .flatMap(IrClassGenerator::getExceptionDefinition)
            .ifPresent(thrownExceptions::add);
    }

    private static void handleMethodEntry(MethodRefEntry method, IrClassGenerator classGenerator, List<MemberRefEntry> staticInvokes) {
        if (IrTypeMapper.mapType(method.typeSymbol().returnType()) instanceof LlvmType.Declared d && d.type().startsWith("java/lang/")) {
            return;
        }
        if (method.typeSymbol()
            .parameterList()
            .stream()
            .map(IrTypeMapper::mapType)
            .anyMatch(t -> t instanceof LlvmType.Declared d && d.type().startsWith("java/lang/"))) {
            return;
        }
        classGenerator.addMethodDependency(method, staticInvokes.contains(method));
    }

    private void handleStringEntry(StringEntry string, IrClassGenerator classGenerator, GlobalInitializer globalInitializer) {
        classGenerator.addStringConstant(string.index(), string.stringValue());
        globalInitializer.addInitializableString(classGenerator, string);
    }

    private AggregateType generateType(LlvmType.Declared type, Map<String, IrClassGenerator> generatedClasses) {
        var generator = generatedClasses.get(type.type());
        if (generator == null) {
            return new AggregateType.Opaque(type);
        }
        return generator.getSimpleType();
    }

    private void generateSuperClass(
        ClassEntry entry,
        IrClassGenerator classGenerator,
        Map<String, IrClassGenerator> generatedClasses,
        FunctionRegistry functionRegistry,
        GlobalInitializer globalInitializer
    ) throws IOException {
        generateClass(entry, generatedClasses, functionRegistry, globalInitializer);
        classGenerator.inherit(generatedClasses.get(entry.name().stringValue()));
    }

    private void generateClass(
        ClassEntry entry,
        Map<String, IrClassGenerator> generatedClasses,
        FunctionRegistry functionRegistry,
        GlobalInitializer globalInitializer
    ) throws IOException {
        var type = Utils.unwrapType(entry);
        if (type.isPrimitive()) return;

        var name = typeName(type);
        if (generatedClasses.containsKey(name)) return;

        ClassBuilder classBuilder;
        if (resolver.contains(name)) {
            if (name.equals("java/lang/Exception")) {
                var generator = new IrClassGenerator("java/lang/Exception", debug, c -> generateType(c, generatedClasses), functionRegistry);
                generator.injectCode("""
                    define void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"*) {
                      ret void
                    }""");
                generator.setException();
                generatedClasses.put("java/lang/Exception", generator);
                return;
            } else {
                if (Blacklist.isSupportedClass(name)) {
                    var superClass = resolver.resolve(entry.name().stringValue());
                    classBuilder = new ClassBuilder(resolver, superClass, classPath, debug);
                } else {
                    System.err.println("Class " + entry.name() + " not supported");
                    return;
                }
            }
        } else {
            var optionalTargetClass = loadClass(name);
            if (optionalTargetClass.isEmpty() && name.startsWith("sun")) return;

            var targetClass = optionalTargetClass.orElseThrow(() -> new IllegalArgumentException("Class " + name + " not found."));
            classBuilder = new ClassBuilder(resolver, targetClass, classPath, debug);
        }

        classBuilder.generate(generatedClasses, functionRegistry, globalInitializer);
    }

    private String typeName(ClassDesc type) {
        var className = type.packageName().replace('.', '/');
        if (!className.isEmpty()) {
            className += "/";
        }
        return className + type.displayName();
    }

    // TODO: join with generateClass
    private Optional<ClassModel> loadClass(ClassEntry classEntry) throws IOException {
        var type = Utils.unwrapType(classEntry);
        if (type.isPrimitive()) return Optional.empty();
        return loadClass(typeName(type));
    }

    private Optional<ClassModel> loadClass(String className) throws IOException {
        if (resolver.contains(className)) {
            if (Blacklist.isSupportedClass(className)) {
                return Optional.of(resolver.resolve(className));
            } else {
                System.err.println("Class " + className + " not supported");
                return Optional.empty();
            }
        } else {
            var targetPath = classPath.resolve(className + ".class");
            if (!Files.exists(targetPath)) {
                System.err.println("Class not found: " + targetPath);
                return Optional.empty();
            }
            return Optional.of(ClassFile.of().parse(targetPath));
        }
    }
}
