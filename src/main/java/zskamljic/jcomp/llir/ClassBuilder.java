package zskamljic.jcomp.llir;

import zskamljic.jcomp.StdLibResolver;
import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.Vtable;
import zskamljic.jcomp.llir.models.VtableInfo;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.CompoundElement;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.classfile.instruction.ThrowInstruction;
import java.lang.constant.ClassDesc;
import java.lang.constant.MethodTypeDesc;
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
        var vtables = generateVtables();
        // TODO: remove when exception compiles
        vtables.put("java/lang/Exception", new Vtable());
        return generate(generated, vtables);
    }

    private Map<String, Vtable> generateVtables() throws IOException {
        var vtables = new HashMap<String, Vtable>();
        generateVtable(classModel, vtables);

        return vtables;
    }

    private Vtable generateVtable(ClassModel current, Map<String, Vtable> vtables) throws IOException {
        var className = current.thisClass().name().stringValue();
        if (vtables.containsKey(className)) return vtables.get(className);

        var vtable = new Vtable();
        if (current.superclass().isPresent()) {
            var parentClass = loadClass(current.superclass().get());
            if (parentClass.isPresent()) {
                var parent = generateVtable(parentClass.get(), vtables);
                vtable.addAll(parent);
            }
        }
        for (var method : current.methods()) {
            if (isUnsupportedFunction(method)) {
                continue;
            }
            if (Utils.isVirtual(method)) {
                var returnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
                var parameterList = generateParameterList(className, method.methodTypeSymbol());
                var functionSignature = new LlvmType.Function(returnType, parameterList);
                var functionName = STR."@\{Utils.methodName(className, method)}";
                vtable.put(
                    method.methodName().stringValue(),
                    method.methodTypeSymbol(),
                    new VtableInfo(functionSignature, functionName)
                );
            }
        }
        vtables.put(className, vtable);

        for (var entry : current.constantPool()) {
            if (entry instanceof ClassEntry classEntry) {
                var referencedClass = loadClass(classEntry);
                if (referencedClass.isPresent()) {
                    generateVtable(referencedClass.get(), vtables);
                } else {
                    vtables.put(classEntry.name().stringValue(), new Vtable());
                }
            } else if (entry instanceof MethodRefEntry method) {
                var owner = method.owner();
                if (vtables.containsKey(owner.name().stringValue())) continue;

                var referencedClass = loadClass(owner);
                if (referencedClass.isPresent()) {
                    generateVtable(referencedClass.get(), vtables);
                } else {
                    vtables.put(owner.name().stringValue(), new Vtable());
                }
            }
        }
        return vtable;
    }

    private static List<LlvmType> generateParameterList(String className, MethodTypeDesc methodTypeSymbol) {
        var parameterList = new ArrayList<LlvmType>();
        parameterList.add(new LlvmType.Pointer(new LlvmType.Declared(className)));
        for (int i = 0; i < methodTypeSymbol.parameterCount(); i++) {
            var parameter = methodTypeSymbol.parameterType(i);
            var type = IrTypeMapper.mapType(parameter);
            parameterList.add(type);
        }
        return parameterList;
    }

    public Map<String, IrClassGenerator> generate(
        Map<String, IrClassGenerator> generatedClasses,
        Map<String, Vtable> vtables
    ) throws IOException {
        var className = classModel.thisClass().name().stringValue();
        var classGenerator = new IrClassGenerator(className, debug, c -> generateType(c, generatedClasses), vtables);

        var thrownExceptions = new ArrayList<String>();
        generatedClasses.put(className, classGenerator);
        if (classModel.superclass().isPresent()) {
            var superclass = classModel.superclass().get();
            generateSuperClass(superclass, classGenerator, generatedClasses, vtables);
            Optional.ofNullable(generatedClasses.get(superclass.name().stringValue()))
                .flatMap(IrClassGenerator::getExceptionDefinition)
                .ifPresent(thrownExceptions::add);
        }
        for (var entry : classModel.constantPool()) {
            if (entry instanceof ClassEntry classEntry) {
                generateClass(classEntry, generatedClasses, vtables);
                classGenerator.addRequiredType(new LlvmType.Declared(classEntry.name().stringValue()));
                Optional.ofNullable(generatedClasses.get(classEntry.name().stringValue()))
                    .flatMap(IrClassGenerator::getExceptionDefinition)
                    .ifPresent(thrownExceptions::add);
            } else if (entry instanceof MethodRefEntry method) {
                if (IrTypeMapper.mapType(method.typeSymbol().returnType()) instanceof LlvmType.Declared d && d.type().startsWith("java/lang/")) {
                    continue;
                }
                if (method.typeSymbol()
                    .parameterList()
                    .stream()
                    .map(IrTypeMapper::mapType)
                    .anyMatch(t -> t instanceof LlvmType.Declared d && d.type().startsWith("java/lang/"))) {
                    continue;
                }
                classGenerator.addMethodDependency(method);
            }
        }

        for (var field : classModel.fields()) {
            var type = IrTypeMapper.mapType(field.fieldTypeSymbol());
            if (type instanceof LlvmType.Declared) {
                type = new LlvmType.Pointer(type);
            }

            classGenerator.addField(field.fieldName().stringValue(), type);
        }

        var hasThrow = false;
        for (var method : classModel.methods()) {
            if (isUnsupportedFunction(method)) {
                continue;
            }
            hasThrow = hasThrow || method.code()
                .stream()
                .flatMap(CompoundElement::elementStream)
                .anyMatch(c -> c instanceof ThrowInstruction);
            classGenerator.addMethod(method);
        }

        classGenerator.injectCode("declare i32 @__gxx_personality_v0(...)");
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

        return generatedClasses;
    }

    private String generateType(LlvmType.Declared type, Map<String, IrClassGenerator> generatedClasses) {
        var generator = generatedClasses.get(type.type());
        if (generator == null) {
            return STR."\{type} = type opaque";
        }
        return generator.getSimpleType();
    }

    private boolean isUnsupportedFunction(MethodModel method) {
        return "wait".equals(method.methodName().stringValue()) ||
            "toString".equals(method.methodName().stringValue()) ||
                "getClass".equals(method.methodName().stringValue()) ||
                "clone".equals(method.methodName().stringValue());
    }

    private void generateSuperClass(
        ClassEntry entry,
        IrClassGenerator classGenerator,
        Map<String, IrClassGenerator> generatedClasses,
        Map<String, Vtable> vtables
    ) throws IOException {
        generateClass(entry, generatedClasses, vtables);
        classGenerator.inherit(generatedClasses.get(entry.name().stringValue()));
    }

    private void generateClass(
        ClassEntry entry,
        Map<String, IrClassGenerator> generatedClasses,
        Map<String, Vtable> vtables
    ) throws IOException {
        var type = unwrapType(entry);
        if (type.isPrimitive()) return;

        var name = typeName(type);
        if (generatedClasses.containsKey(name)) return;

        ClassBuilder classBuilder;
        if (resolver.contains(name)) {
            switch (name) {
                case "java/lang/Object" -> {
                    var superClass = resolver.resolve(entry.name().stringValue());
                    classBuilder = new ClassBuilder(resolver, superClass, classPath, debug);
                }
                case "java/lang/Exception" -> {
                    var generator = new IrClassGenerator("java/lang/Exception", debug, c -> generateType(c, generatedClasses), vtables);
                    generator.injectCode("""
                        define void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"*) {
                          ret void
                        }""");
                    generator.setException();
                    generatedClasses.put("java/lang/Exception", generator);
                    return;
                }
                default -> {
                    System.err.println(STR."Class \{entry.name()} not supported");
                    return;
                }
            }
        } else {
            var targetClass = loadClass(name)
                .orElseThrow(() -> new IllegalArgumentException(STR."Class \{name} not found."));
            classBuilder = new ClassBuilder(resolver, targetClass, classPath, debug);
        }

        generatedClasses.putAll(classBuilder.generate(generatedClasses, vtables));
    }

    private ClassDesc unwrapType(ClassEntry entry) {
        var type = entry.asSymbol();
        while (type.isArray()) {
            type = type.componentType();
        }
        return type;
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
        var type = unwrapType(classEntry);
        if (type.isPrimitive()) return Optional.empty();
        return loadClass(typeName(type));
    }

    private Optional<ClassModel> loadClass(String className) throws IOException {
        if (resolver.contains(className)) {
            if (className.equals("java/lang/Object")) {
                return Optional.of(resolver.resolve(className));
            } else {
                System.err.println(STR."Class \{className} not supported");
                return Optional.empty();
            }
        } else {
            var targetPath = classPath.resolve(STR."\{className}.class");
            if (!Files.exists(targetPath)) {
                System.err.println(STR."Class not found: \{targetPath}");
                return Optional.empty();
            }
            return Optional.of(ClassFile.of().parse(targetPath));
        }
    }
}
