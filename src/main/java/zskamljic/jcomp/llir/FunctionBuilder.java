package zskamljic.jcomp.llir;

import java.lang.classfile.Label;
import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.instruction.ArrayStoreInstruction;
import java.lang.classfile.instruction.ConstantInstruction;
import java.lang.classfile.instruction.FieldInstruction;
import java.lang.classfile.instruction.InvokeInstruction;
import java.lang.classfile.instruction.LineNumber;
import java.lang.classfile.instruction.LoadInstruction;
import java.lang.classfile.instruction.LocalVariable;
import java.lang.classfile.instruction.NewObjectInstruction;
import java.lang.classfile.instruction.NewPrimitiveArrayInstruction;
import java.lang.classfile.instruction.ReturnInstruction;
import java.lang.classfile.instruction.StackInstruction;
import java.lang.classfile.instruction.StoreInstruction;
import java.lang.reflect.AccessFlag;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HashMap;
import java.util.Map;

public class FunctionBuilder {
    private final MethodModel method;
    private final boolean debug;

    public FunctionBuilder(MethodModel method, boolean debug) {
        this.method = method;
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
        var types = new HashMap<String, String>();
        for (var element : code) {
            var line = STR."\{method.methodName()}: \{element}";
            switch (element) {
                case ArrayStoreInstruction as -> currentUnnamed = handleArrayStore(builder, stack, types, as, currentUnnamed);
                case ConstantInstruction c -> handleConstant(stack, c);
                case FieldInstruction f -> currentUnnamed = handleFieldInstruction(builder, stack, f, currentUnnamed);
                case InvokeInstruction i -> currentUnnamed = handleInvoke(builder, stack, i, currentUnnamed);
                case Label _ -> {
                }// TODO: handle labels
                case LineNumber l -> builder.append(STR."  ; Line \{l.line()}\n");
                case LoadInstruction l -> loadValue(stack, locals, l);
                case LocalVariable v -> declareLocal(locals, v);
                case NewObjectInstruction n -> currentUnnamed = handleCreateNewObject(builder, stack, n, currentUnnamed);
                case NewPrimitiveArrayInstruction a -> currentUnnamed = handleCreatePrimitiveArray(builder, stack, types, a, currentUnnamed);
                case ReturnInstruction r -> handleReturn(builder, stack, r, returnType);
                case StackInstruction s -> handleStackInstruction(stack, s);
                case StoreInstruction s -> handleStoreInstruction(builder, stack, locals, s);
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

    private int handleArrayStore(StringBuilder builder, Deque<String> stack, HashMap<String, String> types, ArrayStoreInstruction instruction, int currentUnnamed) {
        var value = stack.pop();
        var index = stack.pop();
        var arrayReference = stack.pop();

        builder.append(" ".repeat(2))
            .append("%").append(currentUnnamed).append(" = getelementptr inbounds ").append(types.get(arrayReference))
            .append(", ptr ").append(arrayReference)
            .append(", i64 0") // Index through array pointer
            .append(", i32 ").append(index) // Index through field
            .append("\n");

        var type = IrTypeMapper.mapType(instruction.typeKind())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{instruction.typeKind()} in not a supported type for array store"));
        builder.append(" ".repeat(2))
            .append("store ").append(type).append(" ").append(value)
            .append(", ptr %").append(currentUnnamed)
            .append("\n");
        currentUnnamed++;
        return currentUnnamed;
    }

    private int handleCreateNewObject(StringBuilder builder, Deque<String> stack, NewObjectInstruction instruction, int currentUnnamed) {
        var varName = STR."%\{currentUnnamed}";
        currentUnnamed++;
        builder.append(" ".repeat(2)).append(varName).append(" = alloca %").append(instruction.className().name()).append("\n");
        stack.push(varName);
        return currentUnnamed;
    }

    private int handleCreatePrimitiveArray(
        StringBuilder builder, Deque<String> stack, Map<String, String> types, NewPrimitiveArrayInstruction instruction, int currentUnnamed
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
        types.put(varName, arrayType);

        currentUnnamed++;
        return currentUnnamed;
    }

    private void handleConstant(Deque<String> stack, ConstantInstruction instruction) {
        switch (instruction.opcode()) {
            case ICONST_M1 -> stack.push("-1");
            case ICONST_0 -> stack.push("0");
            case ICONST_1 -> stack.push("1");
            case ICONST_2 -> stack.push("2");
            case ICONST_3 -> stack.push("3");
            case ICONST_4 -> stack.push("4");
            case ICONST_5 -> stack.push("5");
            case BIPUSH -> stack.push(instruction.constantValue().toString());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} constant is not supported yet");
        }
    }

    private int handleFieldInstruction(StringBuilder builder, Deque<String> stack, FieldInstruction instruction, int currentUnnamed) {
        builder.append(" ".repeat(2));

        if (instruction.opcode() == Opcode.GETFIELD) {
            var varName = STR."%\{currentUnnamed}";
            builder.append(varName).append(" = getelementptr %").append(instruction.field().owner().name()).append(", ")
                .append("%").append(instruction.field().owner().name()).append("* ").append(stack.pop()).append(", ")
                .append("i32 0, i32 0") // Index into pointer (get this) then index to field at index 0 TODO: change index
                .append("\n");

            currentUnnamed++;
            var valueVar = STR."%\{currentUnnamed}";
            builder.append(" ".repeat(2))
                .append(valueVar).append(" = load i32, i32* ").append(varName).append("\n"); // TODO: change type
            stack.push(valueVar);
            currentUnnamed++;
            return currentUnnamed;
        } else if (instruction.opcode() == Opcode.PUTFIELD) {
            var value = stack.pop();
            var objectReference = stack.pop();

            var varName = STR."%\{currentUnnamed}";
            currentUnnamed++;
            builder.append(varName).append(" = getelementptr %").append(instruction.owner().name())
                .append(", %").append(instruction.owner().name()).append("* ")
                .append(objectReference)
                .append(", i32 0, i32 0").append("\n");
            builder.append(" ".repeat(2)).append("store i32 ").append(value).append(", i32* ").append(varName).append("\n");

            return currentUnnamed;
        } else {
            throw new IllegalArgumentException(STR."\{instruction.opcode()} field instruction is not yet supported");
        }
    }

    private int handleInvoke(StringBuilder builder, Deque<String> stack, InvokeInstruction invocation, int currentUnnamed) {
        var returnType = IrTypeMapper.mapType(invocation.typeSymbol().returnType())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{invocation.typeSymbol().returnType()} return type not supported."));
        builder.append(" ".repeat(2));
        if (!returnType.equals("void")) {
            var unnamedName = STR."%\{currentUnnamed}";
            builder.append(unnamedName).append(" = ");
        }

        var functionName = getFunctionName(invocation);

        builder.append("call ").append(returnType).append(" @").append(functionName).append("(");
        var parameters = invocation.typeSymbol().parameterList();
        var paramValues = new ArrayDeque<String>();
        for (var _ : parameters) {
            paramValues.push(stack.pop());
        }
        if (invocation.opcode() != Opcode.INVOKESTATIC) {
            var typeName = STR."%\"\{invocation.method().owner().name()}\"*";
            if (!typeName.contains("/")) {
                typeName = typeName.replaceAll("\"", "");
            }
            builder.append(typeName).append(" ").append(stack.pop()); // Add implicit this
        }
        for (var parameter : parameters) {
            var type = IrTypeMapper.mapType(parameter)
                .orElseThrow(() -> new IllegalArgumentException(STR."\{parameter} parameter type not supported."));
            builder.append(type).append(" ").append(paramValues.pop());
        }
        builder.append(")").append("\n");
        if (!returnType.equals("void")) {
            var unnamedName = STR."%\{currentUnnamed}";
            stack.push(unnamedName);
            return currentUnnamed + 1;
        }
        return currentUnnamed;
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
            case ALOAD_0 -> locals[0];
            case ALOAD_1 -> locals[1];
            case ALOAD_2 -> locals[2];
            case ALOAD_3 -> locals[3];
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} load is not supported yet");
        };
        stack.push(local.varName());
    }

    private void declareLocal(Local[] locals, LocalVariable variable) {
        locals[variable.slot()] = new Local(STR."%\{variable.name()}", variable.typeSymbol().displayName());
    }

    private void handleReturn(StringBuilder builder, Deque<String> stack, ReturnInstruction instruction, String returnType) {
        builder.append(" ".repeat(2)).append("ret ").append(returnType);

        if (instruction.opcode() != Opcode.RETURN) {
            builder.append(" ").append(stack.pop());
        }
        builder.append("\n");
    }

    private void handleStackInstruction(Deque<String> stack, StackInstruction instruction) {
        switch (instruction.opcode()) {
            case POP -> stack.pop();
            case DUP -> stack.push(stack.peekLast());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} stack instruction not supported yet");
        }
    }

    private void handleStoreInstruction(StringBuilder builder, Deque<String> stack, Local[] locals, StoreInstruction instruction) {
        var reference = stack.pop();
        var index = switch (instruction.opcode()) {
            case ASTORE_0 -> 0;
            case ASTORE_1 -> 1;
            case ASTORE_2 -> 2;
            case ASTORE_3 -> 3;
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} store currently not supported");
        };
        var local = locals[index];
        builder.append(" ".repeat(2))
            .append(local.varName()).append(" = bitcast %").append(local.type()).append("* ").append(reference)
            .append(" to %").append(local.type()).append("*")
            .append("\n");
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
}
