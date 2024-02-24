package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.VtableInfo;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.constant.MethodTypeDesc;
import java.lang.reflect.AccessFlag;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

public class ClassBuilder {
    private final ClassModel classModel;
    private final Set<String> definedMethods = new HashSet<>();
    private final Set<String> varargs = new HashSet<>();
    private final Map<MethodTypeDesc, VtableInfo> vtable = new HashMap<>();
    private final boolean debug;

    public ClassBuilder(Path inputClass, boolean debug) throws IOException {
        this.debug = debug;
        var classFile = ClassFile.of();
        classModel = classFile.parse(inputClass);
    }

    public List<String> generate(Path path) throws IOException {
        var className = classModel.thisClass().name();

        try (var output = new PrintWriter(new FileOutputStream(path.resolve(STR."\{className}.ll").toFile()))) {
            // TODO: remove when superclasses are supported
            output.println("%\"java/lang/Object\" = type { }\n");
            output.println("define void @\"java/lang/Object_<init>\"(ptr %this) {\n  ret void\n}\n");

            var fieldNames = generateClass(output, classModel.thisClass(), classModel.methods());

            var methods = new ArrayList<String>();
            for (var method : classModel.methods()) {
                var generated = generateMethod(fieldNames, method);
                if (generated == null) {
                    return List.of();
                }
                if (!definedMethods.contains(generated)) {
                    definedMethods.add(generated);
                    methods.add(generated);
                }
            }
            output.println(String.join("\n\n", methods));
        }
        return List.of(STR."\{className}.ll");
    }

    private List<String> generateClass(PrintWriter output, ClassEntry entry, List<MethodModel> methods) {
        var fieldNames = new ArrayList<String>();
        var fieldDefinitions = new ArrayList<LlvmType>();
        for (var field : classModel.fields()) {
            var type = IrTypeMapper.mapType(field.fieldTypeSymbol());

            fieldDefinitions.add(type);
            fieldNames.add(field.fieldName().stringValue());
        }

        classModel.methods()
            .stream()
            .filter(m -> m.flags().has(AccessFlag.VARARGS))
            .map(m -> m.methodName() + m.methodTypeSymbol().descriptorString())
            .forEach(varargs::add);

        var builder = new StringBuilder();

        var virtualMethods = methods.stream()
            .filter(m -> !m.flags().has(AccessFlag.FINAL))
            .filter(m -> !m.flags().has(AccessFlag.STATIC))
            .filter(m -> !m.methodName().equalsString("<init>"))
            .toList();

        var vtable = generateVtableIfNeeded(builder, virtualMethods, entry.name().stringValue());
        vtable.ifPresent(fieldDefinitions::addFirst);

        var fields = fieldDefinitions.stream()
            .map(Object::toString)
            .collect(Collectors.joining(", "));

        builder.append("%").append(entry.name()).append(" = type { ");
        if (!fields.isBlank()) {
            builder.append(fields).append(" ");
        }

        builder.append("}").append("\n");

        if (vtable.isPresent()) {
            builder.append("\n");
            generateVtableData(builder, virtualMethods, fieldNames, entry.name().stringValue());
        }
        output.println(builder);

        return fieldNames;
    }

    private void generateVtableData(StringBuilder builder, List<MethodModel> virtualMethods, ArrayList<String> fieldNames, String name) {
        for (var method : virtualMethods) {
            var methodDefinition = generateMethod(fieldNames, method);
            builder.append(methodDefinition).append("\n\n");
            definedMethods.add(methodDefinition);
        }

        var vtableType = STR."\{name}_vtable_type";
        builder.append("@").append(name).append("_vtable_data = global %").append(vtableType).append(" {\n");

        for (var entry : vtable.values()) {
            builder.append(" ".repeat(2))
                .append(entry.signature())
                .append(" ")
                .append(entry.functionName())
                .append("\n");
        }

        builder.append("}\n");
    }

    private Optional<LlvmType> generateVtableIfNeeded(StringBuilder builder, List<MethodModel> virtualMethods, String name) {
        if (virtualMethods.isEmpty()) return Optional.empty(); // No need for vtable

        var vtableType = STR."\{name}_vtable_type";
        builder.append("%").append(vtableType).append(" = type { ");

        var functionSignatures = new ArrayList<String>();
        for (var method : virtualMethods) {
            var returnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
            var parameterList = generateParameterList(name, method.methodTypeSymbol());
            var functionSignature = STR."\{returnType}(\{parameterList})";
            functionSignatures.add(STR."\{functionSignature}*");
            var functionName = STR."@\{name}_\{method.methodName()}";
            vtable.put(
                method.methodTypeSymbol(), new VtableInfo(new LlvmType.Pointer(new LlvmType.Function(functionSignature)), vtable.size(), functionName)
            );
        }

        builder.append(String.join(", ", functionSignatures))
            .append(" }\n\n");

        return Optional.of(new LlvmType.Pointer(new LlvmType.Declared(vtableType)));
    }

    private static String generateParameterList(String className, MethodTypeDesc methodTypeSymbol) {
        var parameterList = new ArrayList<LlvmType>();
        parameterList.add(new LlvmType.Pointer(new LlvmType.Declared(className)));
        for (int i = 0; i < methodTypeSymbol.parameterCount(); i++) {
            var parameter = methodTypeSymbol.parameterType(i);
            var type = IrTypeMapper.mapType(parameter);
            parameterList.add(type);
        }
        return parameterList.stream()
            .map(Objects::toString)
            .collect(Collectors.joining(","));
    }

    private String generateMethod(List<String> fieldNames, MethodModel method) {
        if (!method.flags().has(AccessFlag.NATIVE)) {
            var builder = new FunctionBuilder(method, fieldNames, varargs, vtable, debug);
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

        var type = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
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
                parameters.add(IrTypeMapper.mapType(parameter).toString());
            }
        }
        declaration.append(String.join(", ", parameters));
        declaration.append(") nounwind");
        return declaration.toString();
    }
}
