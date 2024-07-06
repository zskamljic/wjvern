package zskamljic.jcomp.llir;

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
import java.util.ArrayList;
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
    private final Function<LlvmType.Declared, String> definitionMapper;
    private final List<LlvmType.Declared> classDependencies = new ArrayList<>();
    private final Set<String> methodDependencies = new HashSet<>();
    private final FunctionRegistry functionRegistry;
    private final Map<String, LlvmType> fields = new LinkedHashMap<>();
    private final Map<String, LlvmType> staticFields = new LinkedHashMap<>();
    private final List<MethodModel> parentMethods = new ArrayList<>();
    private final List<MethodModel> methods = new ArrayList<>();
    private final List<String> injectedCode = new ArrayList<>();
    private boolean isException;

    public IrClassGenerator(
        String className,
        boolean debug,
        Function<LlvmType.Declared, String> definitionMapper,
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
        var declaration = STR."declare \{type} @\{name}(\{parameterString})";
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
        builder.append("%java_Array = type { i32, ptr }");
        if (!requiredTypes.isEmpty()) {
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

        var vtableType = generateVtable(builder);
        builder.append("\n\n");
        generateType(builder, vtableType);
        builder.append("\n\n");

        staticFields.forEach((name, type) -> builder.append(name).append(" = global ").append(type).append(" 0").append("\n"));
        if (!staticFields.isEmpty()) builder.append("\n");

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

        generateVtableData(builder, vtableType);
        builder.append("\n\n");

        var methodString = methods.stream()
            .filter(Predicate.not(Utils::isVirtual))
            .map(this::generateMethod)
            .collect(Collectors.joining("\n\n"));
        builder.append(methodString).append("\n");

        return builder.toString();
    }

    private List<LlvmType.Declared> methodRequiredTypes() {
        return Stream.concat(methods.stream(), parentMethods.stream())
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
    }

    private LlvmType generateVtable(StringBuilder builder) {
        var typeName = Utils.escape(STR."\{className}_vtable_type");
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
        return vtableType;
    }

    private void generateType(StringBuilder builder, LlvmType vtableType) {
        builder.append("%").append(Utils.escape(className)).append(" = type { ")
            .append(new LlvmType.Pointer(vtableType));

        fields.values().forEach(f -> builder.append(", ").append(f));

        builder.append(" }");
    }

    private void generateVtableData(StringBuilder builder, LlvmType vtableType) {
        var vtableTypeData = new LlvmType.Global(Utils.escape(STR."\{className}_vtable_data"));

        builder.append(vtableTypeData).append(" = global ").append(vtableType).append(" {\n");

        var virtualFunctions = functionRegistry.getVirtualFunctions(className);
        if (!virtualFunctions.isEmpty()) {
            var mappings = virtualFunctions.stream()
                .map(vi -> STR."\{vi.signature()}* \{vi.functionName()}")
                .collect(Collectors.joining(",\n  "));
            builder.append(" ".repeat(2))
                .append(mappings)
                .append("\n");
        }

        builder.append("}");
    }

    private String generateMethod(MethodModel method) {
        if (!method.flags().has(AccessFlag.NATIVE)) {
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
            parameters.add(STR."%\{Utils.escape(parent)}*");
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

    public String getSimpleType() {
        var builder = new StringBuilder();
        builder.append("%").append(Utils.escape(className)).append(" = type { ")
            .append(LlvmType.Primitive.POINTER);

        fields.values().forEach(f -> builder.append(", ").append(f));

        builder.append(" }");
        return builder.toString();
    }

    public Optional<String> getExceptionDefinition() {
        if (!isException) return Optional.empty();

        var typeInfoString = STR."\{className}_type_string";
        var typeString = STR."\{className.length()}\{className}\\00";
        var pTypeInfoString = STR."P\{typeInfoString}";
        var pTypeString = STR."P\{className.length()}\{className}\\00";
        var typeInfo = STR."\{className}_type_info";
        var pTypeInfo = STR."P\{className}_type_info";

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
}
