package zskamljic.jcomp.llir;

import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.instruction.ConstantInstruction;
import java.lang.classfile.instruction.InvokeInstruction;
import java.lang.classfile.instruction.ReturnInstruction;
import java.lang.classfile.instruction.StackInstruction;
import java.lang.reflect.AccessFlag;
import java.util.ArrayDeque;
import java.util.Deque;

public class FunctionBuilder {
    private final MethodModel method;

    public FunctionBuilder(MethodModel method) {
        this.method = method;
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
                case ConstantInstruction c -> handleConstant(stack, c);
                case InvokeInstruction i -> currentUnnamed = handleInvoke(builder, stack, i, currentUnnamed);
                case ReturnInstruction r -> handleReturn(builder, stack, r, returnType);
                case StackInstruction s -> handleStackInstruction(stack, s);
                default -> line += ": not handled";
            }
            System.out.println(line);
        }
    }

    private void handleConstant(Deque<String> stack, ConstantInstruction instruction) {
        switch (instruction.opcode()) {
            case ICONST_0 -> stack.push("0");
            case ICONST_1 -> stack.push("1");
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} is not supported yet");
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
            stack.push(unnamedName);
        }
        if (method.methodTypeSymbol().parameterCount() > 0) {
            throw new IllegalArgumentException("Calling functions with parameters not supported yet");
        }
        builder.append("call ").append(returnType).append(" @").append(invocation.method().name()).append("()").append(";\n");
        return currentUnnamed + 1;
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
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} not supported yet");
        }
    }

    private String getMethodDefinition(String returnType) {
        if (method.methodTypeSymbol().parameterCount() > 0) {
            throw new IllegalArgumentException("Methods with parameters are not yet supported");
        }

        return STR."define \{returnType} @\{method.methodName()}() {\n";
    }
}
