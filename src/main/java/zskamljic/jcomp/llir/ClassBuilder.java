package zskamljic.jcomp.llir;

import zskamljic.jcomp.Blacklist;
import zskamljic.jcomp.StdLibResolver;
import zskamljic.jcomp.llir.models.AggregateType;
import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.registries.Registry;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.CompoundElement;
import java.lang.classfile.Opcode;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.classfile.constantpool.StringEntry;
import java.lang.classfile.instruction.ThrowInstruction;
import java.lang.classfile.instruction.TypeCheckInstruction;
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
    public static final String EXCEPTION_NAME = "java/lang/Exception";
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

    public Map<String, IrClassGenerator> generate() {
        var generated = new HashMap<String, IrClassGenerator>();
        var registry = generateRegistry();
        var globalInitializer = new GlobalInitializer();
        generate(generated, registry, globalInitializer);

        globalInitializer.generateEntryPoint(
            classModel.thisClass().name().stringValue(),
            generated,
            c -> generateType(c, generated),
            registry
        );

        return generated;
    }

    private Registry generateRegistry() {
        var registry = new Registry(this::loadClass);
        registry.walk(classModel);

        // TODO: when toString is enabled this will no longer be needed
        var stringClass = loadClass("java/lang/String").orElseThrow();
        registry.walk(stringClass);

        return registry;
    }

    public void generate(
        Map<String, IrClassGenerator> generatedClasses,
        Registry registry,
        GlobalInitializer globalInitializer
    ) {
        var className = classModel.thisClass().name().stringValue();
        var classGenerator = new IrClassGenerator(className, debug, c -> generateType(c, generatedClasses), registry, classModel.flags().has(AccessFlag.INTERFACE));

        var thrownExceptions = new ArrayList<String>();
        generatedClasses.put(className, classGenerator);
        classModel.superclass().ifPresent(parent -> generateParent(generatedClasses, registry, globalInitializer, parent, classGenerator, thrownExceptions));
        handleConstPool(generatedClasses, registry, globalInitializer, classGenerator, thrownExceptions);
        globalInitializer.finishInitialization(classGenerator);
        handleFields(classGenerator);

        handleStaticRequirements(classGenerator, thrownExceptions);

        // TODO: when toString is enabled this will no longer be needed
        var stringClass = loadClass("java/lang/String").orElseThrow();
        handleClassEntry(stringClass.thisClass(), generatedClasses, registry, classGenerator, thrownExceptions, globalInitializer);
    }

    private void handleStaticRequirements(IrClassGenerator classGenerator, List<String> thrownExceptions) {
        var hasThrow = false;
        for (var method : classModel.methods()) {
            if (Blacklist.isUnsupportedFunction(method)) continue;

            hasThrow = hasThrow || method.code()
                .stream()
                .flatMap(CompoundElement::elementStream)
                .anyMatch(c -> c instanceof ThrowInstruction || c instanceof TypeCheckInstruction t && t.opcode() == Opcode.CHECKCAST);
            classGenerator.addMethod(method);
        }

        classGenerator.injectCode("""
            %"java/util/stream/IntStream" = type opaque
            %"java/util/function/BiFunction" = type opaque
            declare i32 @__gxx_personality_v0(...)
            declare i1 @instanceof(ptr,i32)
            declare ptr @type_interface_vtable(ptr,i32)
            declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
            declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
            declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
            declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)""");
        if (hasThrow) {
            classGenerator.injectCode("""
                declare i32 @llvm.eh.typeid.for(ptr)
                declare ptr @__cxa_allocate_exception(i64)
                declare void @__cxa_throw(ptr, ptr, ptr)
                declare ptr @__cxa_begin_catch(ptr)
                declare void @__cxa_end_catch()
                @_ZTVN10__cxxabiv117__class_type_infoE = external global ptr
                @_ZTVN10__cxxabiv119__pointer_type_infoE = external global ptr""");

            thrownExceptions.forEach(classGenerator::injectCode);
        }
    }

    private void generateParent(
        Map<String, IrClassGenerator> generatedClasses,
        Registry registry,
        GlobalInitializer globalInitializer,
        ClassEntry superclass,
        IrClassGenerator classGenerator,
        List<String> thrownExceptions
    ) {
        if (!superclass.name().equalsString(EXCEPTION_NAME) && !isValidSuperclassFor(classModel, superclass)) return;

        generateSuperClass(superclass, classGenerator, generatedClasses, registry, globalInitializer);
        Optional.ofNullable(generatedClasses.get(superclass.name().stringValue()))
            .flatMap(IrClassGenerator::getExceptionDefinition)
            .ifPresent(thrownExceptions::add);
    }

    private void handleConstPool(
        Map<String, IrClassGenerator> generatedClasses,
        Registry registry,
        GlobalInitializer globalInitializer,
        IrClassGenerator classGenerator,
        List<String> thrownExceptions
    ) {
        for (var entry : classModel.constantPool()) {
            switch (entry) {
                case ClassEntry classEntry ->
                    handleClassEntry(classEntry, generatedClasses, registry, classGenerator, thrownExceptions, globalInitializer);
                case MethodRefEntry method -> handleMethodEntry(method, classGenerator, registry);
                case StringEntry string -> handleStringEntry(string, classGenerator, globalInitializer);
                default -> {
                    // No need to do anything
                }
            }
        }
    }

    private void handleFields(IrClassGenerator classGenerator) {
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
    }

    private boolean isValidSuperclassFor(ClassModel current, ClassEntry parent) {
        var parentModel = loadClass(parent);
        return parentModel.filter(classElements -> Utils.isValidSuperclass(current, classElements)).isPresent();
    }

    private void handleClassEntry(
        ClassEntry classEntry,
        Map<String, IrClassGenerator> generatedClasses,
        Registry registry,
        IrClassGenerator classGenerator,
        List<String> thrownExceptions,
        GlobalInitializer globalInitializer
    ) {
        generateClass(classEntry, generatedClasses, registry, globalInitializer);
        var dependent = Utils.unwrapType(classEntry);
        if (!dependent.isPrimitive()) {
            classGenerator.addRequiredType(new LlvmType.Declared(typeName(dependent)));
        }
        Optional.ofNullable(generatedClasses.get(classEntry.name().stringValue()))
            .flatMap(IrClassGenerator::getExceptionDefinition)
            .ifPresent(thrownExceptions::add);
    }

    private static void handleMethodEntry(MethodRefEntry method, IrClassGenerator classGenerator, Registry registry) {
        if (IrTypeMapper.mapType(method.typeSymbol().returnType()) instanceof LlvmType.Declared(var type) &&
            type.startsWith("java/lang/")) {
            return;
        }
        if (method.typeSymbol()
            .parameterList()
            .stream()
            .map(IrTypeMapper::mapType)
            .anyMatch(t -> t instanceof LlvmType.Declared(var type) && type.startsWith("java/lang/"))) {
            return;
        }
        classGenerator.addMethodDependency(method, registry.isStatic(method));
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
        Registry registry,
        GlobalInitializer globalInitializer
    ) {
        generateClass(entry, generatedClasses, registry, globalInitializer);
        classGenerator.inherit(generatedClasses.get(entry.name().stringValue()));
    }

    private void generateClass(
        ClassEntry entry,
        Map<String, IrClassGenerator> generatedClasses,
        Registry registry,
        GlobalInitializer globalInitializer
    ) {
        var type = Utils.unwrapType(entry);
        if (type.isPrimitive()) return;

        var name = typeName(type);
        if (generatedClasses.containsKey(name)) return;

        ClassBuilder classBuilder;
        if (resolver.contains(name)) {
            if (name.equals(EXCEPTION_NAME)) {
                var generator = new IrClassGenerator(
                    EXCEPTION_NAME,
                    debug,
                    c -> generateType(c, generatedClasses),
                    registry,
                    classModel.flags().has(AccessFlag.INTERFACE));
                generator.injectCode("""
                    define void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"*) {
                      ret void
                    }""");
                generator.setException();
                generatedClasses.put(EXCEPTION_NAME, generator);
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

        classBuilder.generate(generatedClasses, registry, globalInitializer);
    }

    private String typeName(ClassDesc type) {
        var className = type.packageName().replace('.', '/');
        if (!className.isEmpty()) {
            className += "/";
        }
        return className + type.displayName();
    }

    private Optional<ClassModel> loadClass(ClassEntry classEntry) {
        var type = Utils.unwrapType(classEntry);
        if (type.isPrimitive()) return Optional.empty();
        return loadClass(typeName(type));
    }

    private Optional<ClassModel> loadClass(String className) {
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
            try {
                return Optional.of(ClassFile.of().parse(targetPath));
            } catch (IOException e) {
                throw new IllegalStateException(e);
            }
        }
    }
}
