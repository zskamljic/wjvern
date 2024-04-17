package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.Vtable;
import zskamljic.jcomp.llir.models.VtableInfo;

import java.lang.classfile.ClassModel;
import java.lang.classfile.CompoundElement;
import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.classfile.instruction.InvokeInstruction;
import java.lang.constant.MethodTypeDesc;
import java.lang.reflect.AccessFlag;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
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
    private final Vtable vtable = new Vtable();
    private final Map<String, LlvmType> fields = new LinkedHashMap<>();
    private final List<MethodModel> parentMethods = new ArrayList<>();
    private final List<MethodModel> methods = new ArrayList<>();
    private final List<String> injectedMethods = new ArrayList<>();
    private final Set<String> varargs = new HashSet<>();

    public IrClassGenerator(String className, boolean debug, Function<LlvmType.Declared, String> definitionMapper) {
        this.className = className;
        this.debug = debug;
        this.definitionMapper = definitionMapper;
    }

    public void inherit(IrClassGenerator parent) {
        vtable.addAll(parent.vtable);
        fields.putAll(parent.fields);
        parentMethods.addAll(parent.methods);
        parentMethods.addAll(parent.parentMethods);
        varargs.addAll(parent.varargs);
    }

    public void addRequiredType(LlvmType.Declared className) {
        classDependencies.add(className);
    }

    public void addField(String name, LlvmType type) {
        fields.put(name, type);
    }

    public void addMethod(MethodModel method) {
        var isNativeVarArg = method.flags().has(AccessFlag.VARARGS) &&
            method.flags().has(AccessFlag.NATIVE);
        var alreadyPresent = isNativeVarArg &&
            methods.stream()
                .filter(m -> m.flags().has(AccessFlag.VARARGS))
                .filter(m -> m.flags().has(AccessFlag.NATIVE))
                .filter(m -> m.methodName().equals(method.methodName()))
                .anyMatch(m -> hasMatchingLeadParams(m, method));

        if (isVirtual(method)) {
            var returnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
            var parameterList = generateParameterList(className, method.methodTypeSymbol());
            var functionSignature = new LlvmType.Function(returnType, parameterList);
            var functionName = STR."@\{Utils.escape(STR."\{className}_\{method.methodName()}")}";
            vtable.put(
                method.methodName().stringValue(),
                method.methodTypeSymbol(),
                new VtableInfo(functionSignature, functionName)
            );
        }

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
        if (isNativeVarArg) {
            varargs.add(method.methodName() + method.methodTypeSymbol().descriptorString());
        }
    }

    public void addMethodDependency(MethodRefEntry method) {
        if (method.owner().name().stringValue().equals(className)) return;

        var type = IrTypeMapper.mapType(method.typeSymbol().returnType());
        List<String> parameters = method.typeSymbol()
            .parameterList()
            .stream()
            .map(IrTypeMapper::mapType)
            .map(Objects::toString)
            .collect(Collectors.toCollection(ArrayList::new));
        parameters.addFirst(new LlvmType.Pointer(new LlvmType.Declared(Utils.escape(method.owner().name().stringValue()))).toString());

        var parameterString = String.join(", ", parameters);

        var name = Utils.escape(STR."\{method.owner().name()}_\{method.name()}");
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

    public String generate() {
        var builder = new StringBuilder();

        var requiredTypes = new HashSet<>(classDependencies);
        requiredTypes.addAll(vtable.requiredTypes());
        requiredTypes.addAll(methodRequiredTypes());
        for (var typeDependency : requiredTypes) {
            if (typeDependency.type().equals(className)) continue;

            builder.append(definitionMapper.apply(typeDependency)).append("\n");
        }
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

        if (methods.stream().anyMatch(this::isVirtual)) {
            var virtualMethodString = methods.stream()
                .filter(this::isVirtual)
                .map(this::generateMethod)
                .collect(Collectors.joining("\n\n"));
            builder.append(virtualMethodString).append("\n\n");
        }

        if (!injectedMethods.isEmpty()) {
            for (var method : injectedMethods) {
                builder.append(method).append("\n\n");
            }
        }

        generateVtableData(builder, vtableType);
        builder.append("\n\n");

        var methodString = methods.stream()
            .filter(Predicate.not(this::isVirtual))
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

        if (!vtable.isEmpty()) {
            var vtableString = vtable.stream()
                .map(VtableInfo::signature)
                .map(LlvmType.Pointer::new)
                .map(Objects::toString)
                .collect(Collectors.joining(", "));
            builder.append(" ").append(vtableString);
        }

        builder.append(" }");
        return vtableType;
    }

    private boolean isVirtual(MethodModel method) {
        return !method.flags().has(AccessFlag.FINAL) &&
            !method.flags().has(AccessFlag.STATIC) &&
            !method.methodName().stringValue().endsWith(">");
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

        if (!vtable.isEmpty()) {
            var mappings = vtable.stream()
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
            var builder = new FunctionBuilder(method, new ArrayList<>(fields.keySet()), varargs, vtable, debug);
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
            var functionName = Utils.escape(STR."\{parent}_\{method.methodName()}");
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

    public void injectMethod(String source) {
        injectedMethods.add(source);
    }

    public String getSimpleType() {
        var builder = new StringBuilder();
        builder.append("%").append(Utils.escape(className)).append(" = type { ")
            .append(LlvmType.Primitive.POINTER);

        fields.values().forEach(f -> builder.append(", ").append(f));

        builder.append(" }");
        return builder.toString();
    }
}
