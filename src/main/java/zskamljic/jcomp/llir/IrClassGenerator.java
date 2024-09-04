package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.AggregateType;
import zskamljic.jcomp.llir.models.FunctionRegistry;
import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.VtableInfo;

import java.lang.classfile.ClassModel;
import java.lang.classfile.CompoundElement;
import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.classfile.instruction.InvokeInstruction;
import java.lang.reflect.AccessFlag;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class IrClassGenerator {
    private final String className;
    private final boolean debug;
    private final Function<LlvmType.Declared, AggregateType> definitionMapper;
    private final Set<LlvmType.Declared> classDependencies = new HashSet<>();
    private final Set<String> methodDependencies = new HashSet<>();
    private final FunctionRegistry functionRegistry;
    private final Map<String, LlvmType> fields = new LinkedHashMap<>();
    private final Map<String, LlvmType> staticFields = new LinkedHashMap<>();
    private final List<StringConstant> constants = new ArrayList<>();
    private final List<MethodModel> parentMethods = new ArrayList<>();
    private final List<MethodModel> methods = new ArrayList<>();
    private final List<String> injectedCode = new ArrayList<>();
    private boolean isException;

    public IrClassGenerator(
        String className,
        boolean debug,
        Function<LlvmType.Declared, AggregateType> definitionMapper,
        FunctionRegistry functionRegistry
    ) {
        isException = "java/lang/Throwable".equals(className);
        this.className = className;
        this.debug = debug;
        this.definitionMapper = definitionMapper;
        this.functionRegistry = functionRegistry;
    }

    public void inherit(IrClassGenerator parent) {
        fields.putAll(parent.fields);
        parentMethods.addAll(parent.methods);
        parentMethods.addAll(parent.parentMethods);
        if (!isException) {
            isException = parent.isException;
        }
    }

    public void setException() {
        isException = true;
    }

    public void addRequiredType(LlvmType.Declared className) {
        classDependencies.add(className);
    }

    public void addField(String name, LlvmType type) {
        fields.put(name, type);
    }

    public void addStaticField(String name, LlvmType type) {
        staticFields.put(name, type);
    }

    public void addStringConstant(int index, String stringConstant) {
        var stringBuilder = new StringBuilder();
        int length = 0;
        for (byte c : stringConstant.getBytes(StandardCharsets.UTF_8)) {
            if (c < ' ') {
                stringBuilder.append("\\").append(String.format("%02X", c));
            } else if (c == '\\') {
                stringBuilder.append("\\\\");
            } else {
                stringBuilder.append((char) c);
            }
            length++;
        }

        constants.add(new StringConstant(index, length, stringBuilder.toString()));
    }

    public void addMethod(MethodModel method) {
        var alreadyPresent = methods.stream()
            .filter(m -> m.flags().has(AccessFlag.VARARGS))
            .filter(m -> m.flags().has(AccessFlag.NATIVE))
            .filter(m -> m.methodName().equals(method.methodName()))
            .anyMatch(m -> hasMatchingLeadParams(m, method));

        method.code()
            .stream()
            .flatMap(CompoundElement::elementStream)
            .filter(InvokeInstruction.class::isInstance)
            .map(InvokeInstruction.class::cast)
            .filter(i -> i.opcode() == Opcode.INVOKEVIRTUAL || i.opcode() == Opcode.INVOKESPECIAL)
            .map(InvokeInstruction::method)
            .filter(MethodRefEntry.class::isInstance)
            .map(MethodRefEntry.class::cast)
            .filter(me -> !me.owner().name().stringValue().equals(className))
            .filter(me -> parentMethods.stream().noneMatch(p -> p.methodName().equals(me.name()) && p.methodTypeSymbol().equals(me.typeSymbol())))
            .distinct()
            .forEach(this::addMethodDependency);

        if (!alreadyPresent) {
            methods.add(method);
        }
    }

    public void addMethodDependency(MethodRefEntry method) {
        addMethodDependency(method, false);
    }

    public void addMethodDependency(MethodRefEntry method, boolean isStatic) {
        if (method.owner().name().stringValue().equals(className)) return;

        var type = IrTypeMapper.mapType(method.typeSymbol().returnType());
        List<String> parameters = method.typeSymbol()
            .parameterList()
            .stream()
            .map(IrTypeMapper::mapType)
            .map(Objects::toString)
            .collect(Collectors.toCollection(ArrayList::new));
        if (!isStatic) {
            parameters.addFirst(new LlvmType.Pointer(new LlvmType.Declared(Utils.escape(method.owner().name().stringValue()))).toString());
        }

        var parameterString = String.join(", ", parameters);

        var name = Utils.methodName(method);
        var declaration = "declare " + type + " @" + name + "(" + parameterString + ")";
        methodDependencies.add(declaration);
    }

    private boolean hasMatchingLeadParams(MethodModel left, MethodModel right) {
        var leftParameters = new ArrayList<>(left.methodTypeSymbol().parameterList());
        leftParameters.removeLast();
        var rightParameters = new ArrayList<>(right.methodTypeSymbol().parameterList());
        rightParameters.removeLast();
        return leftParameters.equals(rightParameters);
    }

    public String generate() {
        var builder = new StringBuilder();

        var requiredTypes = new HashSet<>(classDependencies);
        requiredTypes.addAll(functionRegistry.getRequiredTypes(className));
        requiredTypes.addAll(methodRequiredTypes());
        for (var typeDependency : requiredTypes) {
            if (typeDependency.type().equals(className)) continue;

            builder.append(definitionMapper.apply(typeDependency)).append("\n");
        }
        builder.append("%java_Array = type { i32, ptr }\n");
        var vtableType = new LlvmType.Declared(Utils.vtableTypeName(className));
        if (!className.equals("__entrypoint")) {
            generateType(builder, vtableType);
        }
        builder.append("\n");

        if (!constants.isEmpty()) {
            constants.forEach(entry -> builder.append(createStringConstant(entry)).append("\n"));
            builder.append("\n");
        }

        for (var methodDependency : methodDependencies) {
            builder.append(methodDependency).append("\n");
        }
        if (!methodDependencies.isEmpty()) {
            builder.append("\n");
        }

        for (var parentMethod : parentMethods) {
            var methodDeclaration = declareMethod(parentMethod);
            if (!methodDependencies.contains(methodDeclaration)) {
                builder.append(methodDeclaration).append("\n");
            }
        }
        if (!parentMethods.isEmpty()) {
            builder.append("\n");
        }

        var addedVtableType = false;
        for (LlvmType.Declared t : classDependencies) {
            if (!functionRegistry.getVirtualFunctions(t.type()).isEmpty()) {
                generateVtable(t.type(), builder);
                builder.append("\n");
                addedVtableType = true;
            }
        }
        if (addedVtableType) builder.append("\n");

        generateStatics(builder);

        if (methods.stream().anyMatch(Utils::isVirtual)) {
            var virtualMethodString = methods.stream()
                .filter(Utils::isVirtual)
                .map(this::generateMethod)
                .collect(Collectors.joining("\n\n"));
            builder.append(virtualMethodString).append("\n\n");
        }

        if (!injectedCode.isEmpty()) {
            for (var method : injectedCode) {
                builder.append(method).append("\n\n");
            }
        }

        if (!functionRegistry.getVirtualFunctions(className).isEmpty()) {
            generateVtableData(builder, vtableType);
        }
        builder.append("\n\n");

        var methodString = methods.stream()
            .filter(Predicate.not(Utils::isVirtual))
            .map(this::generateMethod)
            .collect(Collectors.joining("\n\n"));
        builder.append(methodString).append("\n");

        return builder.toString();
    }

    private String createStringConstant(StringConstant entry) {
        var stringType = definitionMapper.apply(new LlvmType.Declared("java/lang/String"));

        var defaultValues = stringType.fields()
            .stream()
            .map(f -> f.isReferenceType() || f instanceof LlvmType.Pointer || f == LlvmType.Primitive.POINTER ? "ptr null" : f + " 0")
            .collect(Collectors.joining(", "));

        return "@string.value." + entry.index() + " = private unnamed_addr constant [" + entry.length() + " x i8] c\"" + entry.content() + "\"\n" +
            "@string.array." + entry.index() + " = private unnamed_addr constant %java_Array { i32 " + entry.length() + ", ptr @string.value." + entry.index() + " }\n" +
            "@string." + entry.index() + " = private global " + stringType.type() + " { " + defaultValues + " }";
    }

    private void generateStatics(StringBuilder builder) {
        staticFields.forEach((name, type) -> {
            builder.append(name).append(" = global ").append(type);
            if (type instanceof LlvmType.Primitive) {
                builder.append(" 0\n");
            } else {
                builder.append(" null\n");
            }
            if (!staticFields.isEmpty()) builder.append("\n");
        });
    }

    private List<LlvmType.Declared> methodRequiredTypes() {
        var externalDependencies = classDependencies.stream()
            .map(t -> functionRegistry.getVirtualFunctions(t.type()))
            .flatMap(Collection::stream)
            .map(VtableInfo::signature)
            .<LlvmType>mapMulti((f, c) -> {
                c.accept(f.returnType());
                f.parameters().forEach(c);
            })
            .filter(LlvmType.Declared.class::isInstance)
            .map(LlvmType.Declared.class::cast)
            .distinct()
            .toList();

        var currentDependencies = Stream.of(methods, parentMethods)
            .flatMap(Collection::stream)
            .<LlvmType>mapMulti((mm, c) -> {
                mm.parent()
                    .map(ClassModel::thisClass)
                    .map(ClassEntry::asSymbol)
                    .map(IrTypeMapper::mapType)
                    .ifPresent(c);
                var ms = mm.methodTypeSymbol();
                c.accept(IrTypeMapper.mapType(ms.returnType()));
                ms.parameterList()
                    .stream()
                    .map(IrTypeMapper::mapType)
                    .forEach(c);
            })
            .filter(LlvmType.Declared.class::isInstance)
            .map(LlvmType.Declared.class::cast)
            .distinct()
            .toList();
        return Stream.of(currentDependencies, externalDependencies)
            .flatMap(Collection::stream)
            .distinct()
            .toList();
    }

    private void generateVtable(String className, StringBuilder builder) {
        var typeName = Utils.vtableTypeName(className);
        var vtableType = new LlvmType.Declared(typeName);
        builder.append(vtableType).append(" = type {");

        var virtualFunctions = functionRegistry.getVirtualFunctions(className);
        if (!virtualFunctions.isEmpty()) {
            var vtableString = virtualFunctions.stream()
                .map(VtableInfo::signature)
                .map(LlvmType.Pointer::new)
                .map(Objects::toString)
                .collect(Collectors.joining(", "));
            builder.append(" ").append(vtableString);
        }

        builder.append(" }");
    }

    private void generateType(StringBuilder builder, LlvmType vtableType) {
        builder.append("%").append(Utils.escape(className)).append(" = type {");

        var allFields = new ArrayList<LlvmType>();
        if (!className.equals("java/lang/Exception")) { // TODO: remove once exception compiles
            allFields.add(new LlvmType.Pointer(vtableType));
        }
        allFields.addAll(fields.values());

        var fieldDefinition = allFields.stream()
            .map(String::valueOf)
            .collect(Collectors.joining(", "));
        if (!fieldDefinition.isBlank()) builder.append(" ");

        builder.append(fieldDefinition);

        builder.append(" }");
    }

    private void generateVtableData(StringBuilder builder, LlvmType vtableType) {
        var vtableTypeData = new LlvmType.Global(Utils.escape(className + "_vtable_data"));

        builder.append(vtableTypeData).append(" = global ").append(vtableType).append(" {\n");

        var virtualFunctions = functionRegistry.getVirtualFunctions(className);
        if (!virtualFunctions.isEmpty()) {
            var mappings = virtualFunctions.stream()
                .map(vi -> vi.signature() + "* " + vi.functionName())
                .collect(Collectors.joining(",\n  "));
            builder.append(" ".repeat(2))
                .append(mappings)
                .append("\n");
        }

        builder.append("}");
    }

    private String generateMethod(MethodModel method) {
        if (!method.flags().has(AccessFlag.NATIVE) && !method.flags().has(AccessFlag.ABSTRACT)) {
            var builder = new FunctionBuilder(method, new ArrayList<>(fields.keySet()), functionRegistry, debug);
            return builder.generate();
        }

        return declareMethod(method);
    }

    private String declareMethod(MethodModel method) {
        var declaration = new StringBuilder();
        declaration.append("declare ");

        var parent = method.parent().orElseThrow().thisClass().name().stringValue();

        var type = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
        declaration.append(type);
        declaration.append(" @");
        if (method.flags().has(AccessFlag.STATIC)) {
            declaration.append(method.methodName());
        } else {
            var functionName = Utils.methodName(parent, method);
            declaration.append(functionName);
        }
        declaration.append("(");
        var parameters = new ArrayList<String>();
        var isVarArg = method.flags().has(AccessFlag.VARARGS);
        var symbol = method.methodTypeSymbol();
        if (!method.flags().has(AccessFlag.STATIC)) {
            parameters.add("%" + Utils.escape(parent) + "*");
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
        declaration.append(")");
        if (method.flags().has(AccessFlag.NATIVE)) {
            declaration.append(" nounwind");
        }
        return declaration.toString();
    }

    public void injectCode(String source) {
        injectedCode.add(source);
    }

    public String getClassName() {
        return className;
    }

    public AggregateType getSimpleType() {
        return new AggregateType.Defined(
            new LlvmType.Declared(Utils.escape(className)),
            Stream.concat(Stream.of(LlvmType.Primitive.POINTER), fields.values().stream()).toList()
        );
    }

    public Optional<String> getExceptionDefinition() {
        if (!isException) return Optional.empty();

        var typeInfoString = className + "_type_string";
        var typeString = className.length() + className + "\\00";
        var pTypeInfoString = "P" + typeInfoString;
        var pTypeString = "P" + className.length() + className + "\\00";
        var typeInfo = className + "_type_info";
        var pTypeInfo = "P" + className + "_type_info";

        var type = """
            @%s = constant [%d x i8] c"%s"
            @%s = constant [%d x i8] c"%s"
            @%s = constant { ptr, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2), ptr @%s }
            @%s = constant { ptr, ptr, i32, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv119__pointer_type_infoE, i64 2), ptr @%s, i32 0, ptr @%s }"""
            .formatted(
                Utils.escape(typeInfoString), typeString.length() - 2, typeString, // size with null terminator is 2 characters
                Utils.escape(pTypeInfoString), pTypeString.length() - 2, pTypeString,
                Utils.escape(typeInfo), Utils.escape(typeInfoString),
                Utils.escape(pTypeInfo), Utils.escape(pTypeInfoString), Utils.escape(typeInfo)
            );
        return Optional.of(type);
    }

    private record StringConstant(int index, int length, String content) {
    }
}
