package zskamljic.jcomp.llir;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.reflect.AccessFlag;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ClassBuilder {
    private final ClassModel classModel;
    private final boolean debug;

    public ClassBuilder(File inputClass, boolean debug) throws IOException {
        this.debug = debug;
        var classFile = ClassFile.of();
        classModel = classFile.parse(inputClass.toPath());
    }

    public List<String> generate() throws IOException {
        var className = classModel.thisClass().name();

        try (var output = new PrintWriter(new FileOutputStream(STR."\{className}.ll"))) {
            // TODO: remove when superclasses are supported
            output.println("%\"java/lang/Object\" = type { }\n");
            output.println("define void @\"java/lang/Object_<init>\"(ptr %this) {\n  ret void\n}\n");

            var fieldNames = generateClass(output, classModel.thisClass());

            var varargs = new HashSet<String>();
            classModel.methods()
                .stream()
                .filter(m -> m.flags().has(AccessFlag.VARARGS))
                .map(m -> m.methodName() + m.methodTypeSymbol().descriptorString())
                .forEach(varargs::add);

            var declared = new HashSet<String>();
            var methods = new ArrayList<String>();
            for (var method : classModel.methods()) {
                var generated = generateMethod(fieldNames, method, varargs);
                if (generated == null) {
                    return List.of();
                }
                if (!declared.contains(generated)) {
                    declared.add(generated);
                    methods.add(generated);
                }
            }
            output.println(String.join("\n\n", methods));
        }
        return List.of(STR."\{className}.ll");
    }

    private List<String> generateClass(PrintWriter output, ClassEntry entry) {
        var builder = new StringBuilder();
        builder.append("%").append(entry.name()).append(" = type { ");

        var fieldNames = new ArrayList<String>();
        var fieldDefinitions = new ArrayList<String>();
        for (var field : classModel.fields()) {
            var type = IrTypeMapper.mapType(field.fieldTypeSymbol())
                .orElseThrow(() -> new IllegalArgumentException(STR."Invalid field type \{field.fieldType()} for field \{field.fieldName()}"));

            fieldDefinitions.add(type);
            fieldNames.add(field.fieldName().stringValue());
        }
        var fields = String.join(", ", fieldDefinitions);
        if (!fields.isBlank()) {
            builder.append(fields).append(" ");
        }

        builder.append("}").append("\n");
        output.println(builder);
        return fieldNames;
    }

    private String generateMethod(List<String> fieldNames, MethodModel method, Set<String> varargs) {
        if (!method.flags().has(AccessFlag.NATIVE)) {
            var builder = new FunctionBuilder(method, fieldNames, varargs, debug);
            try {
                return builder.generate();
            } catch (IllegalArgumentException e) {
                System.err.println(e.getMessage());
                return null;
            }
        }

        return declareNative(method);
    }

    private String declareNative(MethodModel method) {
        var declaration = new StringBuilder();
        declaration.append("declare ");

        var type = IrTypeMapper.mapType(method.methodTypeSymbol().returnType())
            .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported type: \{method.methodTypeSymbol().returnType()}"));
        declaration.append(type);
        declaration.append(" @").append(method.methodName()).append("(");
        var parameters = new ArrayList<String>();
        var isVarArg = method.flags().has(AccessFlag.VARARGS);
        var symbol = method.methodTypeSymbol();
        for (int i = 0; i < symbol.parameterCount(); i++) {
            var parameter = symbol.parameterType(i);
            if (isVarArg && i == symbol.parameterCount() - 1) {
                parameters.add("...");
            } else {
                parameters.add(IrTypeMapper.mapType(parameter).orElseThrow(() -> new IllegalArgumentException(STR."\{parameter} type not supported in declare")));
            }
        }
        declaration.append(String.join(", ", parameters));
        declaration.append(") nounwind");
        return declaration.toString();
    }
}
