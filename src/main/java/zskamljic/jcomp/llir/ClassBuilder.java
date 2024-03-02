package zskamljic.jcomp.llir;

import zskamljic.jcomp.StdLibResolver;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

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
        var generatedClasses = new HashMap<String, IrClassGenerator>();

        var className = classModel.thisClass().name().stringValue();
        var classGenerator = new IrClassGenerator(className, debug);
        if (classModel.superclass().isPresent()) {
            generateSuperClass(classModel.superclass().get(), classGenerator, generatedClasses);
        }

        for (var field : classModel.fields()) {
            var type = IrTypeMapper.mapType(field.fieldTypeSymbol());

            classGenerator.addField(field.fieldName().stringValue(), type);
        }

        for (var method : classModel.methods()) {
            if (isUnsupportedFunction(method)) {
                continue;
            }
            classGenerator.addMethod(method);
        }

        generatedClasses.put(className, classGenerator);

        return generatedClasses;
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
        ClassBuilder classBuilder;
        if (entry.name().stringValue().startsWith("java/lang")) {
            var superClass = resolver.resolve(entry.name().stringValue());

            classBuilder = new ClassBuilder(resolver, superClass, classPath, debug);
        } else {
            classBuilder = new ClassBuilder(resolver, classPath.resolve(STR."\{entry.name()}.class"), debug);
        }

        generatedClasses.putAll(classBuilder.generate());
        classGenerator.inherit(generatedClasses.get(entry.name().stringValue()));
    }
}
