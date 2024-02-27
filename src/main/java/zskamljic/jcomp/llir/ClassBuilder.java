package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.Vtable;
import zskamljic.jcomp.llir.models.VtableInfo;

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
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

public class ClassBuilder {
    private final ClassModel classModel;
    private final Set<String> definedMethods = new HashSet<>();
    private final Set<String> varargs = new HashSet<>();
    private final Vtable vtable = new Vtable();
    private final Path classPath;
    private final boolean debug;
    private final List<LlvmType> fieldDefinitions = new ArrayList<>();
    private final List<String> fieldNames = new ArrayList<>();
    private final List<String> parentClasses = new ArrayList<>();

    public ClassBuilder(Path inputClass, boolean debug) throws IOException {
        this.debug = debug;
        var classFile = ClassFile.of();
        classModel = classFile.parse(inputClass);
        classPath = inputClass.getParent();
    }

    public void generate(PrintWriter output, Path path) throws IOException {
        if (classModel.superclass().isPresent()) {
            generateSuperClass(output, classModel.superclass().get(), path);
        }

        if (parentClasses.isEmpty()) {
            // TODO: remove when superclasses are supported
            output.println("%\"java/lang/Object\" = type { }\n");
            output.println("define void @\"java/lang/Object_<init>\"(ptr %this) {\n  ret void\n}\n");
        } else {
            output.println();
        }

        var fieldNames = generateClass(output, classModel.thisClass(), classModel.methods());

        var methods = new ArrayList<String>();
        for (var method : classModel.methods()) {
            if (!method.flags().has(AccessFlag.FINAL) &&
                !method.flags().has(AccessFlag.STATIC) &&
                !method.methodName().stringValue().endsWith(">")
            ) {
                continue;
            }

            var generated = generateMethod(fieldNames, method);
            if (generated == null) {
                return;
            }
            if (!definedMethods.contains(generated)) {
                definedMethods.add(generated);
                methods.add(generated);
            } else {
                System.err.println(STR."Generated \{method} more than once");
            }
        }
        output.println(String.join("\n\n", methods));
    }

    private void generateSuperClass(PrintWriter writer, ClassEntry entry, Path path) throws IOException {
        if (entry.name().stringValue().startsWith("java/lang")) return; // TODO: add stdlib and remove this

        var classBuilder = new ClassBuilder(classPath.resolve(STR."\{entry.name()}.class"), debug);
        classBuilder.generate(writer, path);
        fieldDefinitions.addAll(classBuilder.fieldDefinitions);
        fieldNames.addAll(classBuilder.fieldNames);
        parentClasses.addAll(classBuilder.parentClasses);
        parentClasses.add(entry.name().stringValue());
        vtable.addAll(classBuilder.vtable);
    }

    private List<String> generateClass(PrintWriter output, ClassEntry entry, List<MethodModel> methods) {
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

        var fields = fieldDefinitions.stream()
            .map(Object::toString)
            .collect(Collectors.joining(", "));

        builder.append("%").append(entry.name()).append(" = type { ");
        vtable.ifPresent(vt -> {
            builder.append(vt);
            if (!fields.isBlank()) builder.append(",");
            builder.append(" ");
        });
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

    private void generateVtableData(StringBuilder builder, List<MethodModel> virtualMethods, List<String> fieldNames, String name) {
        for (var method : virtualMethods) {
            var methodDefinition = generateMethod(fieldNames, method);
            builder.append(methodDefinition).append("\n\n");
            definedMethods.add(methodDefinition);
        }

        var vtableType = STR."\{name}_vtable_type";
        builder.append("@").append(name).append("_vtable_data = global %").append(vtableType).append(" {\n");

        var functions = vtable.stream()
            .map(vt -> STR."  \{vt.signature()}* \{vt.functionName()}")
            .collect(Collectors.joining(",\n"));
        builder.append(functions).append("\n");

        builder.append("}\n");
    }

    private Optional<LlvmType> generateVtableIfNeeded(StringBuilder builder, List<MethodModel> virtualMethods, String name) {
        if (virtualMethods.isEmpty()) return Optional.empty(); // No need for vtable

        var vtableType = STR."\{name}_vtable_type";
        builder.append("%").append(vtableType).append(" = type { ");

        var functionSignatures = new ArrayList<String>();
        vtable.stream()
            .map(VtableInfo::signature)
            .map(s -> STR."\{s.toString()}*")
            .forEach(functionSignatures::add);
        for (var method : virtualMethods) {
            var returnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
            var parameterList = generateParameterList(name, method.methodTypeSymbol());
            var functionSignature = new LlvmType.Function(returnType, parameterList);
            functionSignatures.add(new LlvmType.Pointer(functionSignature).toString());
            var functionName = STR."@\{name}_\{method.methodName()}";
            vtable.put(
                method.methodName().stringValue(),
                method.methodTypeSymbol(),
                new VtableInfo(functionSignature, functionName)
            );
        }

        builder.append(String.join(", ", functionSignatures))
            .append(" }\n\n");

        return Optional.of(new LlvmType.Pointer(new LlvmType.Declared(vtableType)));
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

        return declareMethod(method);
    }

    private String declareMethod(MethodModel method) {
        var declaration = new StringBuilder();
        declaration.append("declare ");

        var parent = method.parent().orElseThrow().thisClass().name();

        var type = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
        declaration.append(type);
        declaration.append(" @");
        if (method.flags().has(AccessFlag.STATIC)) {
            declaration.append(method.methodName());
        } else {
            var functionName = STR."\"\{parent}_\{method.methodName()}\"";
            if (!functionName.contains("<")) {
                functionName = functionName.replaceAll("\"", "");
            }
            declaration.append(functionName);
        }
        declaration.append("(");
        var parameters = new ArrayList<String>();
        var isVarArg = method.flags().has(AccessFlag.VARARGS);
        var symbol = method.methodTypeSymbol();
        if (!method.flags().has(AccessFlag.STATIC)) {
            parameters.add(STR."%\{parent}* %this");
        }
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
