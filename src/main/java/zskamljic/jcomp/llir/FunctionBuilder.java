package zskamljic.jcomp.llir;

import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.instruction.ArrayStoreInstruction;
import java.lang.classfile.instruction.ConstantInstruction;
import java.lang.classfile.instruction.InvokeInstruction;
import java.lang.classfile.instruction.LineNumber;
import java.lang.classfile.instruction.NewPrimitiveArrayInstruction;
import java.lang.classfile.instruction.ReturnInstruction;
import java.lang.classfile.instruction.StackInstruction;
import java.lang.reflect.AccessFlag;
import java.util.ArrayDeque;
import java.util.Deque;

public class FunctionBuilder {
    private final MethodModel method;
    private final boolean debug;

    public FunctionBuilder(MethodModel method, boolean debug) {
        this.method = method;
        this.debug = debug;
    }

    public String generate() {
        if (!method.flags().has(AccessFlag.STATIC)) {
            throw new IllegalArgumentException("Non-static functions are not yet supported");
        }

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
        for (var element : code) {
            var line = STR."\{method.methodName()}: \{element}";
            switch (element) {
                case ArrayStoreInstruction as -> currentUnnamed = handleArrayStore(builder, stack, as, currentUnnamed);
                case ConstantInstruction c -> handleConstant(stack, c);
                case InvokeInstruction i -> currentUnnamed = handleInvoke(builder, stack, i, currentUnnamed);
                case LineNumber l -> builder.append(STR."  ; Line \{l.line()}\n");
                case NewPrimitiveArrayInstruction a -> currentUnnamed = handleCreatePrimitiveArray(builder, stack, a, currentUnnamed);
                case ReturnInstruction r -> handleReturn(builder, stack, r, returnType);
                case StackInstruction s -> handleStackInstruction(stack, s);
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

    private int handleArrayStore(StringBuilder builder, Deque<String> stack, ArrayStoreInstruction instruction, int currentUnnamed) {
        var value = stack.pop();
        var index = stack.pop();
        var arrayReference = stack.pop();

        var type = IrTypeMapper.mapType(instruction.typeKind())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{instruction.typeKind()} in not a supported type for array store"));

        builder.append(" ".repeat(2))
            .append("%").append(currentUnnamed).append(" = getelementptr inbounds ").append(type)
            .append(", ptr ").append(arrayReference)
            .append(", i32 ").append(index)
            .append(";\n");
        builder.append(" ".repeat(2))
            .append("store ").append(type).append(" ").append(value)
            .append(", ptr %").append(currentUnnamed)
            .append(";\n");
        currentUnnamed++;
        return currentUnnamed;
    }

    private int handleCreatePrimitiveArray(StringBuilder builder, Deque<String> stack, NewPrimitiveArrayInstruction instruction, int currentUnnamed) {
        builder.append(" ".repeat(2))
            .append("%").append(currentUnnamed).append(" = alloca ");

        var type = IrTypeMapper.mapType(instruction.typeKind())
            .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported type \{instruction.typeKind()}"));
        builder.append(type).append(", i32 ").append(stack.pop()).append(";\n");
        stack.push(STR."%\{currentUnnamed}");

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

    private int handleInvoke(StringBuilder builder, Deque<String> stack, InvokeInstruction invocation, int currentUnnamed) {
        var isSameClass = method.parent()
            .map(parent -> invocation.owner().equals(parent.thisClass()))
            .orElse(false);
        if (!isSameClass) {
            throw new IllegalArgumentException("Calling methods from other classes is not yet supported");
        }

        var returnType = IrTypeMapper.mapType(invocation.typeSymbol().returnType())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{invocation.typeSymbol().returnType()} return type not supported."));
        builder.append(" ".repeat(2));
        if (!returnType.equals("void")) {
            var unnamedName = STR."%\{currentUnnamed}";
            builder.append(unnamedName).append(" = ");
        }
        builder.append("call ").append(returnType).append(" @").append(invocation.method().name()).append("(");
        var parameters = invocation.typeSymbol().parameterList();
        var paramValues = new ArrayDeque<String>();
        for (var _ : parameters) {
            paramValues.push(stack.pop());
        }
        for (var parameter : parameters) {
            var type = IrTypeMapper.mapType(parameter)
                .orElseThrow(() -> new IllegalArgumentException(STR."\{parameter} parameter type not supported."));
            builder.append(type).append(" ").append(paramValues.pop());
        }
        builder.append(")").append(";\n");
        if (!returnType.equals("void")) {
            var unnamedName = STR."%\{currentUnnamed}";
            stack.push(unnamedName);
            return currentUnnamed + 1;
        }
        return currentUnnamed;
    }

    private void handleReturn(StringBuilder builder, Deque<String> stack, ReturnInstruction instruction, String returnType) {
        builder.append(" ".repeat(2)).append("ret ").append(returnType);

        if (instruction.opcode() != Opcode.RETURN) {
            builder.append(" ").append(stack.pop());
        }
        builder.append(";\n");
    }

    private void handleStackInstruction(Deque<String> stack, StackInstruction instruction) {
        switch (instruction.opcode()) {
            case POP -> stack.pop();
            case DUP -> stack.push(stack.peekLast());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} stack instruction not supported yet");
        }
    }

    private String getMethodDefinition(String returnType) {
        if (method.methodTypeSymbol().parameterCount() > 0) {
            throw new IllegalArgumentException("Methods with parameters are not yet supported");
        }

        return STR."define \{returnType} @\{method.methodName()}() {\n";
    }
}
