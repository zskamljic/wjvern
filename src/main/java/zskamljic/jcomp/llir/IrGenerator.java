package zskamljic.jcomp.llir;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.MethodModel;
import java.lang.reflect.AccessFlag;
import java.util.List;

public class IrGenerator {
    private final ClassModel classModel;

    public IrGenerator(File inputClass) throws IOException {
        var classFile = ClassFile.of();
        classModel = classFile.parse(inputClass.toPath());
    }

    public List<String> generate() throws IOException {
        var className = classModel.thisClass().name();
        try (var output = new PrintWriter(new FileOutputStream(STR."\{className}.ll"))) {
            var methods = classModel.methods();
            for (var method : methods) {
                generateMethod(output, method);
            }
        }
        return List.of(STR."\{className}.ll");
    }

    private static void generateMethod(PrintWriter output, MethodModel method) {
        if (method.methodName().equalsString("<init>")) {
            System.err.println("Constructors are not yet supported");
            return;
        }
        if (!method.flags().has(AccessFlag.NATIVE)) {
            var builder = new FunctionBuilder(method);
            try {
                var result = builder.generate();
                output.println(result);
            } catch (IllegalArgumentException e) {
                System.err.println(e.getMessage());
            }
            return;
        }

        declareNative(output, method);
    }

    private static void declareNative(PrintWriter output, MethodModel method) {
        var declaration = new StringBuilder();
        declaration.append("declare ");

        var type = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
        declaration.append(type);
        declaration.append(" @").append(method.methodName()).append("() nounwind");
        output.println(declaration);
    }
}
