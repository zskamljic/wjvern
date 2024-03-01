package zskamljic.jcomp.llir;

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

    public ClassBuilder(Path inputClass, boolean debug) throws IOException {
        this.debug = debug;
        var classFile = ClassFile.of();
        classModel = classFile.parse(inputClass);
        classPath = inputClass.getParent();
    }

    public Map<String, IrClassGenerator> generate(Path path) throws IOException {
        var generatedClasses = new HashMap<String, IrClassGenerator>();

        var className = classModel.thisClass().name().stringValue();
        var classGenerator = new IrClassGenerator(className, debug);
        if (classModel.superclass().isPresent()) {
            generateSuperClass(classModel.superclass().get(), path, classGenerator, generatedClasses);
        }

        for (var field : classModel.fields()) {
            var type = IrTypeMapper.mapType(field.fieldTypeSymbol());

            classGenerator.addField(field.fieldName().stringValue(), type);
        }

        for (var method : classModel.methods()) {
            classGenerator.addMethod(method);
        }

        for (var constPoolEntry : classModel.constantPool()) {
            if (constPoolEntry instanceof ClassEntry c) {
                if (c.equals(classModel.thisClass())) continue;

                classGenerator.addTypeDependency(c.name().stringValue());
            }
        }

        generatedClasses.put(className, classGenerator);

        return generatedClasses;
    }

    private void generateSuperClass(
        ClassEntry entry, Path path, IrClassGenerator classGenerator, Map<String, IrClassGenerator> generatedClasses
    ) throws IOException {
        if (entry.name().stringValue().startsWith("java/lang")) {
            var objectBuilder = new IrClassGenerator("java/lang/Object", debug);
            objectBuilder.injectMethod("""
                define void @"java/lang/Object_<init>"(%"java/lang/Object"* %this) {
                    ret void
                }
                """);
            generatedClasses.put("java/lang/Object", objectBuilder);
            classGenerator.inherit(objectBuilder);
            return; // TODO: add stdlib and remove this
        }

        var classBuilder = new ClassBuilder(classPath.resolve(STR."\{entry.name()}.class"), debug);
        generatedClasses.putAll(classBuilder.generate(path));
        classGenerator.inherit(generatedClasses.get(entry.name().stringValue()));
    }
}
