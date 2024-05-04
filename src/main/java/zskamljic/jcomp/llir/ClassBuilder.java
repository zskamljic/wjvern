package zskamljic.jcomp.llir;

import zskamljic.jcomp.StdLibResolver;
import zskamljic.jcomp.llir.models.LlvmType;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.CompoundElement;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.classfile.instruction.ThrowInstruction;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class ClassBuilder {
    private final ClassModel classModel;
    private final Path classPath;
    private final boolean debug;
    private final StdLibResolver resolver;

    public ClassBuilder(StdLibResolver resolver, Path inputClass, boolean debug) throws IOException {
        this(resolver, ClassFile.of().parse(inputClass), inputClass.getParent(), debug);
    }

    public ClassBuilder(StdLibResolver resolver, ClassModel classModel, Path classPath, boolean debug) {
        this.resolver = resolver;
        this.debug = debug;
        this.classModel = classModel;
        this.classPath = classPath;
    }

    public Map<String, IrClassGenerator> generate() throws IOException {
        var generated = new HashMap<String, IrClassGenerator>();
        return generate(generated);
    }

    public Map<String, IrClassGenerator> generate(Map<String, IrClassGenerator> generatedClasses) throws IOException {
        var className = classModel.thisClass().name().stringValue();
        var classGenerator = new IrClassGenerator(className, debug, c -> generateType(c, generatedClasses));

        var thrownExceptions = new ArrayList<String>();
        generatedClasses.put(className, classGenerator);
        if (classModel.superclass().isPresent()) {
            var superclass = classModel.superclass().get();
            generateSuperClass(superclass, classGenerator, generatedClasses);
            Optional.ofNullable(generatedClasses.get(superclass))
                .flatMap(IrClassGenerator::getExceptionDefinition)
                .ifPresent(thrownExceptions::add);
        }
        for (var entry : classModel.constantPool()) {
            if (entry instanceof ClassEntry classEntry) {
                generateClass(classEntry, generatedClasses);
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
            "hashCode".equals(method.methodName().stringValue()) ||
            "clone".equals(method.methodName().stringValue());
    }

    private void generateSuperClass(
        ClassEntry entry, IrClassGenerator classGenerator, Map<String, IrClassGenerator> generatedClasses
    ) throws IOException {
        generateClass(entry, generatedClasses);
        classGenerator.inherit(generatedClasses.get(entry.name().stringValue()));
    }

    private void generateClass(ClassEntry entry, Map<String, IrClassGenerator> generatedClasses) throws IOException {
        if (generatedClasses.containsKey(entry.name().stringValue())) return;

        ClassBuilder classBuilder;
        if (entry.name().stringValue().startsWith("java/lang")) {
            switch (entry.name().stringValue()) {
                case "java/lang/Object" -> {
                    var superClass = resolver.resolve(entry.name().stringValue());

                    classBuilder = new ClassBuilder(resolver, superClass, classPath, debug);
                }
                case "java/lang/Exception" -> {
                    var generator = new IrClassGenerator("java/lang/Exception", debug, c -> generateType(c, generatedClasses));
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
            var tagetPath = classPath.resolve(STR."\{entry.name()}.class");
            if (!Files.exists(tagetPath)) {
                System.err.println(STR."Class not found: \{tagetPath}");
                return;
            }
            classBuilder = new ClassBuilder(resolver, tagetPath, debug);
        }

        generatedClasses.putAll(classBuilder.generate(generatedClasses));
    }
}
