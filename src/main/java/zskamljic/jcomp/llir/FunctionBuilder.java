package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;

import java.lang.classfile.Label;
import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.instruction.ArrayStoreInstruction;
import java.lang.classfile.instruction.BranchInstruction;
import java.lang.classfile.instruction.ConstantInstruction;
import java.lang.classfile.instruction.FieldInstruction;
import java.lang.classfile.instruction.IncrementInstruction;
import java.lang.classfile.instruction.InvokeInstruction;
import java.lang.classfile.instruction.LineNumber;
import java.lang.classfile.instruction.LoadInstruction;
import java.lang.classfile.instruction.LocalVariable;
import java.lang.classfile.instruction.NewObjectInstruction;
import java.lang.classfile.instruction.NewPrimitiveArrayInstruction;
import java.lang.classfile.instruction.OperatorInstruction;
import java.lang.classfile.instruction.ReturnInstruction;
import java.lang.classfile.instruction.StackInstruction;
import java.lang.classfile.instruction.StoreInstruction;
import java.lang.reflect.AccessFlag;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class FunctionBuilder {
    private final MethodModel method;
    private final List<String> fieldDefinition;
    private final Set<String> varargs;
    private final boolean debug;

    public FunctionBuilder(MethodModel method, List<String> fieldNames, Set<String> varargs, boolean debug) {
        this.method = method;
        this.fieldDefinition = fieldNames;
        this.varargs = varargs;
        this.debug = debug;
    }

    public String generate() {
        var optionalReturnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
        if (optionalReturnType.isEmpty()) {
            throw new IllegalArgumentException(STR."Unsupported return type: \{method.methodTypeSymbol().returnType()}");
        }

        var returnType = optionalReturnType.get();
        var builder = new StringBuilder();
        builder.append(getMethodDefinition(returnType));
        generateCode(builder, returnType);
        builder.append("}");

        return builder.toString();
    }

    private void generateCode(StringBuilder builder, String returnType) {
        var optionalCode = method.code();
        if (optionalCode.isEmpty()) return;

        var code = optionalCode.get();
        var currentUnnamed = 1;
        var locals = new Local[code.maxLocals()];
        var stack = new ArrayDeque<String>();
        var types = new HashMap<String, LlvmType>();
        var labelGenerator = new LabelGenerator();
        for (var it = code.iterator(); it.hasNext(); ) {
            var element = it.next();
            var line = STR."\{method.methodName()}: \{element}";
            switch (element) {
                case ArrayStoreInstruction as -> currentUnnamed = handleArrayStore(builder, stack, types, as, currentUnnamed);
                case BranchInstruction b -> currentUnnamed = handleBranch(builder, stack, types, labelGenerator, b, currentUnnamed);
                case ConstantInstruction c -> handleConstant(stack, c);
                case FieldInstruction f -> currentUnnamed = handleFieldInstruction(builder, stack, f, currentUnnamed);
                case IncrementInstruction i -> currentUnnamed = handleIncrement(builder, locals, i, currentUnnamed);
                case InvokeInstruction i -> currentUnnamed = handleInvoke(builder, stack, types, i, currentUnnamed);
                case Label label -> {
                    if (it.hasNext()) { // Ignore labels at end of block
                        // TODO: don't build multiple strings
                        var content = builder.toString();
                        if (content.trim().endsWith("{")) {
                            currentUnnamed--;
                        }
                        var lastNewLine = content.lastIndexOf("\n", content.length() - 2);
                        if (lastNewLine != -1 && !content.substring(lastNewLine).trim().startsWith("br")) {
                            builder.append(" ".repeat(2)).append("br label %").append(labelGenerator.getLabel(label)).append("\n");
                        }
                        builder.append(labelGenerator.getLabel(label)).append(":\n");
                    }
                }
                case LineNumber l -> builder.append(STR."  ; Line \{l.line()}\n");
                case LoadInstruction l -> loadValue(stack, locals, l);
                case LocalVariable v -> declareLocal(locals, types, v);
                case NewObjectInstruction n -> currentUnnamed = handleCreateNewObject(builder, stack, n, currentUnnamed);
                case NewPrimitiveArrayInstruction a -> currentUnnamed = handleCreatePrimitiveArray(builder, stack, types, a, currentUnnamed);
                case OperatorInstruction o -> currentUnnamed = handleOperatorInstruction(builder, stack, o, currentUnnamed);
                case ReturnInstruction r -> currentUnnamed = handleReturn(builder, stack, types, r, returnType, currentUnnamed);
                case StackInstruction s -> handleStackInstruction(stack, s);
                case StoreInstruction s -> handleStoreInstruction(builder, stack, locals, types, s);
                default -> line += ": not handled";
            }
            if (debug) {
                System.out.println(line);
            }
        }
        if (debug && !stack.isEmpty()) {
            System.out.println("Remaining on stack: ");
            while (!stack.isEmpty()) {
                System.out.println(stack.pop());
            }
        }
    }

    private int handleArrayStore(StringBuilder builder, Deque<String> stack, Map<String, LlvmType> types, ArrayStoreInstruction instruction, int currentUnnamed) {
        var value = stack.pop();
        var index = stack.pop();
        var arrayReference = stack.pop();

        var varName = STR."%\{currentUnnamed}";
        builder.append(" ".repeat(2))
            .append(varName).append(" = getelementptr inbounds ").append(types.get(arrayReference))
            .append(", ptr ").append(arrayReference)
            .append(", i64 0") // Index through array pointer
            .append(", i32 ").append(index) // Index through field
            .append("\n");
        currentUnnamed++;

        var type = IrTypeMapper.mapType(instruction.typeKind())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{instruction.typeKind()} in not a supported type for array store"));
        if (types.get(value) instanceof LlvmType.Pointer p) {
            var tempValue = STR."%\{currentUnnamed}";
            currentUnnamed++;
            builder.append(" ".repeat(2))
                .append(tempValue).append(" = load ").append(p.type())
                .append(", ").append(p.type()).append("* ").append(value)
                .append("\n");
            value = tempValue;
        }
        builder.append(" ".repeat(2))
            .append("store ").append(type).append(" ").append(value)
            .append(", ptr ").append(varName)
            .append("\n");
        return currentUnnamed;
    }

    private int handleBranch(
        StringBuilder builder, Deque<String> stack, Map<String, LlvmType> types, LabelGenerator labelGenerator, BranchInstruction instruction, int currentUnnamed
    ) {
        switch (instruction.opcode()) {
            case GOTO -> builder.append(" ".repeat(2)).append("br label %").append(labelGenerator.getLabel(instruction.target())).append("\n");
            case IFNE -> {
                var value = stack.pop();
                var target = labelGenerator.getLabel(instruction.target());
                builder.append(" ".repeat(2)).append("br i1 ").append(value)
                    .append(", label %").append(target)
                    .append(", label %not_").append(target)
                    .append("\n");
                builder.append("not_").append(target).append(":\n");
            }
            case IF_ICMPGE -> {
                var b = loadIfNeeded(builder, types, stack.pop(), currentUnnamed);
                currentUnnamed = b.currentUnnamed();
                var a = loadIfNeeded(builder, types, stack.pop(), currentUnnamed);
                currentUnnamed = a.currentUnnamed();

                var varName = STR."%\{currentUnnamed}";
                currentUnnamed++;
                builder.append(" ".repeat(2))
                    .append(varName).append(" = icmp sge i32 ").append(a.name()).append(", ").append(b.name())
                    .append("\n");
                var target = labelGenerator.getLabel(instruction.target());
                builder.append(" ".repeat(2))
                    .append("br i1 ").append(varName)
                    .append(", label %").append(target)
                    .append(", label %not_").append(target)
                    .append("\n");
                builder.append("not_").append(target).append(":\n");
            }
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} jump not supported yet");
        }
        return currentUnnamed;
    }

    private LoadResult loadIfNeeded(StringBuilder builder, Map<String, LlvmType> types, String name, int currentUnnamed) {
        if (types.get(name) instanceof LlvmType.Pointer) {
            var variableValue = STR."%\{currentUnnamed}";
            builder.append(" ".repeat(2))
                .append(variableValue).append(" = load i32, ptr ").append(name)
                .append("\n");
            currentUnnamed++;
            return new LoadResult(currentUnnamed, variableValue);
        }
        return new LoadResult(currentUnnamed, name);
    }

    private int handleCreateNewObject(StringBuilder builder, Deque<String> stack, NewObjectInstruction instruction, int currentUnnamed) {
        var varName = STR."%\{currentUnnamed}";
        currentUnnamed++;
        builder.append(" ".repeat(2)).append(varName).append(" = alloca %").append(instruction.className().name()).append("\n");
        stack.push(varName);
        return currentUnnamed;
    }

    private int handleCreatePrimitiveArray(
        StringBuilder builder, Deque<String> stack, Map<String, LlvmType> types, NewPrimitiveArrayInstruction instruction, int currentUnnamed
    ) {
        var type = IrTypeMapper.mapType(instruction.typeKind())
            .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported type \{instruction.typeKind()}"));

        var size = stack.pop();
        String arrayType;
        if (size.matches("\\d+")) {
            arrayType = STR."[\{size} x \{type}]";
        } else {
            throw new IllegalArgumentException("Dynamic arrays are not supported yet");
        }
        builder.append(" ".repeat(2))
            .append("%").append(currentUnnamed).append(" = alloca ").append(arrayType).append("\n");
        var varName = STR."%\{currentUnnamed}";
        stack.push(varName);
        types.put(varName, new LlvmType.Array(Integer.parseInt(size), type));

        currentUnnamed++;
        return currentUnnamed;
    }

    private int handleOperatorInstruction(StringBuilder builder, Deque<String> stack, OperatorInstruction instruction, int currentUnnamed) {
        var operand2 = stack.pop();
        var operand1 = stack.pop();

        var resultVar = STR."%\{currentUnnamed}";
        stack.push(resultVar);
        currentUnnamed++;

        builder.append(" ".repeat(2));

        switch (instruction.opcode()) {
            case IADD -> builder.append(resultVar).append(" = add i32 ").append(operand1).append(", ").append(operand2).append("\n");
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} is not supported yet");
        }
        return currentUnnamed;
    }

    private void handleConstant(Deque<String> stack, ConstantInstruction instruction) {
        switch (instruction.opcode()) {
            case BIPUSH -> stack.push(instruction.constantValue().toString());
            case ICONST_M1 -> stack.push("-1");
            case ICONST_0 -> stack.push("0");
            case ICONST_1 -> stack.push("1");
            case ICONST_2 -> stack.push("2");
            case ICONST_3 -> stack.push("3");
            case ICONST_4 -> stack.push("4");
            case ICONST_5 -> stack.push("5");
            case FCONST_0 -> stack.push("0.0");
            case FCONST_1 -> stack.push("1.0");
            case FCONST_2 -> stack.push("2.0");
            case LDC, LDC2_W -> stack.push(((ConstantInstruction.LoadConstantInstruction) instruction).constantEntry().constantValue().toString());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} constant is not supported yet");
        }
    }

    private int handleFieldInstruction(StringBuilder builder, Deque<String> stack, FieldInstruction instruction, int currentUnnamed) {
        builder.append(" ".repeat(2));

        if (instruction.opcode() == Opcode.GETFIELD) {
            var varName = STR."%\{currentUnnamed}";

            var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol())
                .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported field type: \{instruction.field().type()}"));

            builder.append(varName).append(" = getelementptr %").append(instruction.field().owner().name()).append(", ")
                .append("%").append(instruction.field().owner().name()).append("* ").append(stack.pop()).append(", ")
                .append("i32 0, i32 ").append(fieldDefinition.indexOf(instruction.field().name().stringValue())).append("\n");

            currentUnnamed++;
            var valueVar = STR."%\{currentUnnamed}";
            builder.append(" ".repeat(2))
                .append(valueVar).append(" = load ").append(fieldType)
                .append(", ").append(fieldType).append("* ").append(varName).append("\n");
            stack.push(valueVar);
            currentUnnamed++;
            return currentUnnamed;
        } else if (instruction.opcode() == Opcode.PUTFIELD) {
            var value = stack.pop();
            var objectReference = stack.pop();

            var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol())
                .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported field type: \{instruction.field().type()}"));

            var varName = STR."%\{currentUnnamed}";
            currentUnnamed++;
            builder.append(varName).append(" = getelementptr %").append(instruction.owner().name())
                .append(", %").append(instruction.owner().name()).append("* ")
                .append(objectReference)
                .append(", i32 0, ")
                .append("i32 ").append(fieldDefinition.indexOf(instruction.field().name().stringValue())).append("\n");
            builder.append(" ".repeat(2)).append("store ").append(fieldType).append(" ").append(value).append(", ")
                .append(fieldType).append("* ").append(varName).append("\n");

            return currentUnnamed;
        } else {
            throw new IllegalArgumentException(STR."\{instruction.opcode()} field instruction is not yet supported");
        }
    }

    private int handleIncrement(StringBuilder builder, Local[] locals, IncrementInstruction instruction, int currentUnnamed) {
        var source = switch (instruction.opcode()) {
            case IINC -> locals[instruction.slot()];
            default -> throw new IllegalArgumentException(STR."Unsupported increment type \{instruction.opcode()}");
        };
        var valueName = STR."%\{currentUnnamed}";
        currentUnnamed++;
        builder.append(" ".repeat(2))
            .append(valueName).append(" = load ").append(source.type())
            .append(", ptr ").append(source.varName())
            .append("\n");
        var updatedName = STR."%\{currentUnnamed}";
        currentUnnamed++;
        builder.append(" ".repeat(2))
            .append(updatedName).append(" = add ").append(source.type()).append(" ").append(valueName)
            .append(", ").append(instruction.constant())
            .append("\n");
        builder.append(" ".repeat(2))
            .append("store ").append(source.type()).append(" ").append(updatedName)
            .append(", ptr ").append(source.varName())
            .append("\n");

        return currentUnnamed;
    }

    private int handleInvoke(StringBuilder builder, Deque<String> stack, Map<String, LlvmType> types, InvokeInstruction invocation, int currentUnnamed) {
        var isVarArg = varargs.contains(invocation.method().name() + invocation.typeSymbol().descriptorString());

        var parameterCount = invocation.typeSymbol().parameterCount();
        if (isVarArg) {
            var parameter = stack.pop();
            if (types.get(parameter) instanceof LlvmType.Array array) {
                parameterCount = parameterCount - 1 + array.length();
                for (int i = 0; i < array.length(); i++) {
                    var pointerName = STR."%\{currentUnnamed}";
                    currentUnnamed++;
                    builder.append(" ".repeat(2))
                        .append(pointerName).append(" = getelementptr inbounds ").append(array).append(", ptr ").append(parameter)
                        .append(", i64 0, i32 ").append(i).append("\n");
                    var varName = STR."%\{currentUnnamed}";
                    currentUnnamed++;
                    builder.append(" ".repeat(2))
                        .append(varName).append(" = load ").append(array.type()).append(", ").append(array.type()).append("* ").append(pointerName)
                        .append("\n");
                    switch (array.type()) {
                        case "float" -> {
                            var extendedName = STR."%\{currentUnnamed}";
                            currentUnnamed++;
                            builder.append(" ".repeat(2)).append(extendedName).append(" = fpext float ").append(varName).append(" to double\n");
                            stack.push(extendedName);
                        }
                        case "i8", "i16" -> {
                            var extendedName = STR."%\{currentUnnamed}";
                            currentUnnamed++;
                            builder.append(" ".repeat(2)).append(extendedName).append(" = sext ").append(array.type()).append(" ").append(varName).append(" to i32\n");
                            stack.push(extendedName);
                        }
                        default -> stack.push(varName);
                    }
                }
            }
        }

        var returnType = IrTypeMapper.mapType(invocation.typeSymbol().returnType())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{invocation.typeSymbol().returnType()} return type not supported."));
        builder.append(" ".repeat(2));
        if (!returnType.equals("void")) {
            var unnamedName = STR."%\{currentUnnamed}";
            builder.append(unnamedName).append(" = ");
        }

        var functionName = getFunctionName(invocation);

        builder.append("call ").append(returnType).append(" @").append(functionName).append("(");
        var paramValues = new ArrayDeque<String>();
        for (int i = parameterCount - 1; i >= 0; i--) {
            var type = invocation.typeSymbol().parameterType(Math.min(i, invocation.typeSymbol().parameterCount()));
            var shouldUnwrap = isVarArg && i >= invocation.typeSymbol().parameterCount() - 1;
            if (type.isArray() && shouldUnwrap) type = type.componentType();

            var finalType = type;
            var irType = IrTypeMapper.mapType(type)
                .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported parameter type \{finalType}"));
            if (shouldUnwrap) {
                irType = extendType(irType);
            }

            paramValues.push(STR."\{irType} \{stack.pop()}");
        }
        if (invocation.opcode() != Opcode.INVOKESTATIC) {
            var typeName = STR."%\"\{invocation.method().owner().name()}\"*";
            if (!typeName.contains("/")) {
                typeName = typeName.replaceAll("\"", "");
            }
            builder.append(typeName).append(" ").append(stack.pop()); // Add implicit this
        }
        builder.append(String.join(", ", paramValues));
        builder.append(")").append("\n");
        if (!returnType.equals("void")) {
            var unnamedName = STR."%\{currentUnnamed}";
            stack.push(unnamedName);
            return currentUnnamed + 1;
        }
        return currentUnnamed;
    }

    private String extendType(String irType) {
        return switch (irType) {
            case "float" -> "double";
            case "i8", "i16" -> "i32";
            default -> irType;
        };
    }

    private String getFunctionName(InvokeInstruction invoke) {
        return switch (invoke.opcode()) {
            case INVOKESPECIAL, INVOKEVIRTUAL -> STR."\"\{invoke.method().owner().name()}_\{invoke.method().name()}\"";
            case INVOKESTATIC -> invoke.method().name().stringValue();
            default -> throw new IllegalArgumentException(STR."\{invoke.opcode()} invocation not yet supported");
        };
    }

    private void loadValue(Deque<String> stack, Local[] locals, LoadInstruction instruction) {
        var local = switch (instruction.opcode()) {
            case ALOAD_0, ILOAD_0 -> locals[0];
            case ALOAD_1, ILOAD_1 -> locals[1];
            case ALOAD_2, ILOAD_2 -> locals[2];
            case ALOAD_3, ILOAD_3 -> locals[3];
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} load is not supported yet");
        };
        stack.push(local.varName());
    }

    private void declareLocal(Local[] locals, Map<String, LlvmType> types, LocalVariable variable) {
        locals[variable.slot()] = new Local(STR."%\{variable.name()}", IrTypeMapper.mapType(variable.typeSymbol())
            .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported type \{variable.typeSymbol().displayName()}")));

        var type = IrTypeMapper.mapType(variable.typeSymbol())
            .orElseThrow(() -> new IllegalArgumentException(STR."Local of type \{variable.typeSymbol()} is not supported"));
        if (type.equals("ptr")) {
            throw new IllegalArgumentException(STR."Locals of type \{variable.typeSymbol()} not yet supported");
        }
        types.put(STR."%\{variable.name().stringValue()}", new LlvmType.Pointer(type));
    }

    private int handleReturn(StringBuilder builder, Deque<String> stack, Map<String, LlvmType> types, ReturnInstruction instruction, String returnType, int currentUnnamed) {
        if (instruction.opcode() != Opcode.RETURN) {
            if (types.get(stack.peekFirst()) instanceof LlvmType.Pointer p) {
                var varName = STR."%\{currentUnnamed}";
                currentUnnamed++;
                builder.append(" ".repeat(2))
                    .append(varName).append(" = ").append("load ").append(p.type()).append(", ptr ").append(stack.pop())
                    .append("\n");
                stack.push(varName);
            }
        }

        builder.append(" ".repeat(2)).append("ret ").append(returnType);

        // Plain return does not have a value
        if (instruction.opcode() != Opcode.RETURN) {
            builder.append(" ").append(stack.pop());
        }
        builder.append("\n");
        return currentUnnamed;
    }

    private void handleStackInstruction(Deque<String> stack, StackInstruction instruction) {
        switch (instruction.opcode()) {
            case POP -> stack.pop();
            case DUP -> stack.push(stack.peekFirst());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} stack instruction not supported yet");
        }
    }

    private void handleStoreInstruction(StringBuilder builder, Deque<String> stack, Local[] locals, Map<String, LlvmType> types, StoreInstruction instruction) {
        var reference = stack.pop();
        var index = switch (instruction.opcode()) {
            case ASTORE_0, ISTORE_0 -> 0;
            case ASTORE_1, ISTORE_1 -> 1;
            case ASTORE_2, ISTORE_2 -> 2;
            case ASTORE_3, ISTORE_3 -> 3;
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} store currently not supported");
        };
        var local = locals[index];
        if (reference.startsWith("%")) {
            builder.append(" ".repeat(2))
                .append(local.varName()).append(" = bitcast %").append(local.type()).append("* ").append(reference)
                .append(" to %").append(local.type()).append("*")
                .append("\n");
        } else {
            builder.append(" ".repeat(2))
                .append(local.varName()).append(" = alloca ").append(types.get(local.varName()))
                .append("\n");
            builder.append(" ".repeat(2))
                .append("store ").append(types.get(local.varName())).append(" ").append(reference)
                .append(", ptr ").append(local.varName())
                .append("\n");
        }
    }

    private String getMethodDefinition(String returnType) {
        if (method.methodTypeSymbol().parameterCount() > 0) {
            throw new IllegalArgumentException("Methods with parameters are not yet supported");
        }

        var methodQualifier = "";
        if (!method.flags().has(AccessFlag.STATIC)) {
            var parentClass = method.parent()
                .orElseThrow(() -> new IllegalArgumentException(STR."Non static function \{method.methodName()} has no parent"));
            methodQualifier = STR."\{parentClass.thisClass().name()}_";
        }

        var methodName = method.methodName().stringValue();
        if (!methodQualifier.isBlank()) {
            methodName = methodQualifier + methodName;
        }

        if (methodName.contains("<")) {
            methodName = STR."\"\{methodName}\"";
        }

        if (method.methodTypeSymbol().parameterCount() != 0) {
            throw new IllegalArgumentException("Functions with parameters are not yet supported");
        }

        var parametes = "";
        if (!method.flags().has(AccessFlag.STATIC)) {
            var parent = method.parent().orElseThrow();
            parametes = STR."%\{parent.thisClass().name()}* %this";
        }

        return STR."define \{returnType} @\{methodName}(\{parametes}) {\n";
    }

    record LoadResult(int currentUnnamed, String name) {
    }
}
