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
import java.util.ArrayList;
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
        var parent = method.parent()
            .orElseThrow(() -> new IllegalArgumentException("Method must have a parent class"))
            .thisClass()
            .name()
            .stringValue();

        var name = method.methodName().stringValue();
        if (!method.flags().has(AccessFlag.STATIC)) {
            name = STR."\{parent}_\{name}";
        }

        var returnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType())
            .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported method return type: \{method.methodTypeSymbol().returnType()}"));

        var codeGenerator = new IrCodeGenerator(
            returnType,
            name
        );
        if (!method.flags().has(AccessFlag.STATIC)) {
            codeGenerator.addParameter("this", new LlvmType.Pointer(new LlvmType.Declared(parent)));
        }

        generateCode(codeGenerator);

        return codeGenerator.generate();
    }

    private void generateCode(IrCodeGenerator generator) {
        var optionalCode = method.code();
        if (optionalCode.isEmpty()) return;

        var code = optionalCode.get();
        var locals = new Local[code.maxLocals()];
        var stack = new ArrayDeque<String>();
        var types = new HashMap<String, LlvmType>();
        var labelGenerator = new LabelGenerator();
        var unnamedGenerator = new UnnamedGenerator();
        for (var it = code.iterator(); it.hasNext(); ) {
            var element = it.next();
            var line = STR."\{method.methodName()}: \{element}";
            switch (element) {
                case ArrayStoreInstruction as -> handleArrayStore(generator, stack, types, as, unnamedGenerator);
                case BranchInstruction b -> handleBranch(generator, stack, types, labelGenerator, b, unnamedGenerator);
                case ConstantInstruction c -> handleConstant(stack, c);
                case FieldInstruction f -> handleFieldInstruction(generator, stack, f, unnamedGenerator);
                case IncrementInstruction i -> handleIncrement(generator, locals, i, unnamedGenerator);
                case InvokeInstruction i -> handleInvoke(generator, stack, types, i, unnamedGenerator);
                case Label label -> {
                    if (it.hasNext()) { // Ignore labels at end of block
                        // TODO: move to IrCodeGenerator
                        if (generator.isEmpty()) {
                            unnamedGenerator.skipAnonymousBlock();
                        }
                        generator.label(labelGenerator.getLabel(label));
                    }
                }
                case LineNumber l -> generator.comment(STR."Line \{l.line()}");
                case LoadInstruction l -> loadValue(stack, locals, l);
                case LocalVariable v -> declareLocal(locals, types, v);
                case NewObjectInstruction n -> handleCreateNewObject(generator, stack, types, n, unnamedGenerator);
                case NewPrimitiveArrayInstruction a -> handleCreatePrimitiveArray(generator, stack, types, a, unnamedGenerator);
                case OperatorInstruction o -> handleOperatorInstruction(generator, stack, types, o, unnamedGenerator);
                case ReturnInstruction r -> handleReturn(generator, stack, types, r, unnamedGenerator);
                case StackInstruction s -> handleStackInstruction(stack, s);
                case StoreInstruction s -> handleStoreInstruction(generator, stack, locals, types, s);
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

    private void handleArrayStore(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ArrayStoreInstruction instruction, UnnamedGenerator unnamed
    ) {
        var value = stack.pop();
        var index = stack.pop();
        var arrayReference = stack.pop();

        var varName = unnamed.generateNext();
        generator.getElementPointer(varName, types.get(arrayReference), LlvmType.Primitive.POINTER, arrayReference, index);

        var type = IrTypeMapper.mapType(instruction.typeKind())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{instruction.typeKind()} in not a supported type for array store"));
        value = loadPointerIfNeeded(generator, types, unnamed, value);
        generator.store(type, value, LlvmType.Primitive.POINTER, varName);
    }

    private static String loadPointerIfNeeded(IrCodeGenerator generator, Map<String, LlvmType> types, UnnamedGenerator unnamed, String value) {
        if (types.get(value) instanceof LlvmType.Pointer p) {
            var tempValue = unnamed.generateNext();
            generator.load(tempValue, p.type(), p, value);
            value = tempValue;
        }
        return value;
    }

    private void handleBranch(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, LabelGenerator labelGenerator, BranchInstruction instruction, UnnamedGenerator unnamed
    ) {
        switch (instruction.opcode()) {
            case GOTO -> generator.branchLabel(labelGenerator.getLabel(instruction.target()));
            case IF_ICMPGE -> {
                var b = loadIfNeeded(generator, types, stack.pop(), unnamed);
                var a = loadIfNeeded(generator, types, stack.pop(), unnamed);

                var varName = unnamed.generateNext();
                generator.compare(varName, IrCodeGenerator.Condition.GREATER_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFLE -> {
                var value = stack.pop();
                value = loadPointerIfNeeded(generator, types, unnamed, value);

                var varName = unnamed.generateNext();
                generator.compare(varName, IrCodeGenerator.Condition.LESS_EQUAL, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFNE -> {
                var value = stack.pop();
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(value, ifTrue, ifFalse);
                generator.label(ifFalse);
            }

            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} jump not supported yet");
        }
    }

    private String loadIfNeeded(IrCodeGenerator generator, Map<String, LlvmType> types, String name, UnnamedGenerator unnamed) {
        if (types.get(name) instanceof LlvmType.Pointer p) {
            var variableValue = unnamed.generateNext();
            generator.load(variableValue, p.type(), p, name);
            return variableValue;
        }
        return name;
    }

    private void handleCreateNewObject(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, NewObjectInstruction instruction, UnnamedGenerator unnamed
    ) {
        var varName = unnamed.generateNext();
        generator.alloca(varName, new LlvmType.Declared(instruction.className().name().stringValue()));
        types.put(varName, new LlvmType.Pointer(new LlvmType.Declared(instruction.className().name().stringValue())));
        stack.push(varName);
    }

    private void handleCreatePrimitiveArray(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, NewPrimitiveArrayInstruction instruction, UnnamedGenerator unnamed
    ) {
        var type = IrTypeMapper.mapType(instruction.typeKind())
            .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported type \{instruction.typeKind()}"));

        var size = stack.pop();
        LlvmType.Array arrayType;
        if (size.matches("\\d+")) {
            arrayType = new LlvmType.Array(Integer.parseInt(size), type);
        } else {
            throw new IllegalArgumentException("Dynamic arrays are not supported yet");
        }
        var varName = unnamed.generateNext();
        generator.alloca(varName, arrayType);
        stack.push(varName);
        types.put(varName, arrayType);
    }

    private void handleOperatorInstruction(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, OperatorInstruction instruction, UnnamedGenerator unnamed
    ) {
        var operand2 = loadPointerIfNeeded(generator, types, unnamed, stack.pop());
        var operand1 = loadPointerIfNeeded(generator, types, unnamed, stack.pop());

        var resultVar = unnamed.generateNext();
        stack.push(resultVar);

        // TODO: parameterize by type
        switch (instruction.opcode()) {
            case DADD -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.ADD, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DDIV -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.DIV, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DMUL -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.MUL, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DSUB -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.SUB, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case FADD -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.ADD, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FDIV -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.DIV, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FMUL -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.MUL, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FSUB -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.SUB, LlvmType.Primitive.FLOAT, operand1, operand2);
            case IADD -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.ADD, LlvmType.Primitive.INT, operand1, operand2);
            case IDIV -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.DIV, LlvmType.Primitive.INT, operand1, operand2);
            case IMUL -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.MUL, LlvmType.Primitive.INT, operand1, operand2);
            case ISUB -> generator.binaryOperator(resultVar, IrCodeGenerator.Operator.SUB, LlvmType.Primitive.INT, operand1, operand2);
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} is not supported yet");
        }
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
            case DCONST_0, FCONST_0 -> stack.push("0.0");
            case DCONST_1, FCONST_1 -> stack.push("1.0");
            case FCONST_2 -> stack.push("2.0");
            case LDC, LDC2_W -> stack.push(((ConstantInstruction.LoadConstantInstruction) instruction).constantEntry().constantValue().toString());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} constant is not supported yet");
        }
    }

    private void handleFieldInstruction(IrCodeGenerator generator, Deque<String> stack, FieldInstruction instruction, UnnamedGenerator unnamed) {

        if (instruction.opcode() == Opcode.GETFIELD) {
            var varName = unnamed.generateNext();

            var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol())
                .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported field type: \{instruction.field().type()}"));

            var parentType = new LlvmType.Declared(instruction.field().owner().name().stringValue());
            generator.getElementPointer(
                varName, parentType, new LlvmType.Pointer(parentType), stack.pop(),
                String.valueOf(fieldDefinition.indexOf(instruction.field().name().stringValue()))
            );

            var valueVar = unnamed.generateNext();
            generator.load(valueVar, fieldType, new LlvmType.Pointer(fieldType), varName);
            stack.push(valueVar);
        } else if (instruction.opcode() == Opcode.PUTFIELD) {
            var value = stack.pop();
            var objectReference = stack.pop();

            var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol())
                .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported field type: \{instruction.field().type()}"));

            var varName = unnamed.generateNext();
            var parentType = new LlvmType.Declared(instruction.field().owner().name().stringValue());
            generator.getElementPointer(
                varName, parentType, new LlvmType.Pointer(parentType), objectReference,
                String.valueOf(fieldDefinition.indexOf(instruction.field().name().stringValue()))
            );
            generator.store(fieldType, value, new LlvmType.Pointer(fieldType), varName);
        } else {
            throw new IllegalArgumentException(STR."\{instruction.opcode()} field instruction is not yet supported");
        }
    }

    private void handleIncrement(IrCodeGenerator generator, Local[] locals, IncrementInstruction instruction, UnnamedGenerator unnamed) {
        var source = switch (instruction.opcode()) {
            case IINC -> locals[instruction.slot()];
            default -> throw new IllegalArgumentException(STR."Unsupported increment type \{instruction.opcode()}");
        };
        var valueName = unnamed.generateNext();
        generator.load(valueName, source.type(), new LlvmType.Pointer(source.type()), source.varName());
        var updatedName = unnamed.generateNext();
        generator.binaryOperator(updatedName, IrCodeGenerator.Operator.ADD, (LlvmType.Primitive) source.type(), valueName, String.valueOf(instruction.constant()));
        generator.store(source.type(), updatedName, new LlvmType.Pointer(source.type()), source.varName());
    }

    private void handleInvoke(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, InvokeInstruction invocation, UnnamedGenerator unnamed
    ) {
        var isVarArg = varargs.contains(invocation.method().name() + invocation.typeSymbol().descriptorString());

        var parameterCount = invocation.typeSymbol().parameterCount();
        if (isVarArg) {
            var parameter = stack.pop();
            if (types.get(parameter) instanceof LlvmType.Array array) {
                parameterCount = parameterCount - 1 + array.length();
                for (int i = 0; i < array.length(); i++) {
                    var pointerName = unnamed.generateNext();
                    generator.getElementPointer(pointerName, array, LlvmType.Primitive.POINTER, parameter, String.valueOf(i));
                    var varName = unnamed.generateNext();
                    generator.load(varName, array.type(), new LlvmType.Pointer(array.type()), pointerName);
                    switch (array.type()) {
                        case LlvmType.Primitive p when p == LlvmType.Primitive.FLOAT -> {
                            var extendedName = unnamed.generateNext();
                            generator.floatingPointExtend(extendedName, varName);
                            stack.push(extendedName);
                        }
                        case LlvmType.Primitive p when p == LlvmType.Primitive.BYTE || p == LlvmType.Primitive.SHORT -> {
                            var extendedName = unnamed.generateNext();
                            generator.signedExtend(extendedName, array.type(), "i32", varName);
                            stack.push(extendedName);
                        }
                        default -> stack.push(varName);
                    }
                }
            }
        }

        var parameters = new ArrayList<Map.Entry<String, LlvmType>>();
        // Parameters are on stack, reverse order
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

            parameters.addFirst(Map.entry(stack.pop(), irType));
        }
        // Add implicit this
        if (invocation.opcode() != Opcode.INVOKESTATIC) {
            var typeName = STR."\"\{invocation.method().owner().name()}\"";
            if (!typeName.contains("/")) {
                typeName = typeName.replaceAll("\"", "");
            }
            parameters.addFirst(Map.entry(stack.pop(), new LlvmType.Pointer(new LlvmType.Declared(typeName))));
        }

        var returnType = IrTypeMapper.mapType(invocation.typeSymbol().returnType())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{invocation.typeSymbol().returnType()} return type not supported."));

        String returnVar = null;
        if (returnType != LlvmType.Primitive.VOID) {
            returnVar = unnamed.generateNext();
        }

        var functionName = getFunctionName(invocation);
        generator.invoke(returnVar, returnType, functionName, parameters);

        if (returnType != LlvmType.Primitive.VOID) {
            stack.push(returnVar);
        }
    }

    private LlvmType extendType(LlvmType type) {
        return switch (type) {
            case LlvmType.Primitive p when p == LlvmType.Primitive.FLOAT -> LlvmType.Primitive.DOUBLE;
            case LlvmType.Primitive p when p == LlvmType.Primitive.BYTE || p == LlvmType.Primitive.SHORT -> LlvmType.Primitive.INT;
            default -> type;
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
            case ALOAD_0, DLOAD_0, FLOAD_0, ILOAD_0 -> locals[0];
            case ALOAD_1, DLOAD_1, FLOAD_1, ILOAD_1 -> locals[1];
            case ALOAD_2, DLOAD_2, FLOAD_2, ILOAD_2 -> locals[2];
            case ALOAD_3, DLOAD_3, FLOAD_3, ILOAD_3 -> locals[3];
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} load is not supported yet");
        };
        stack.push(local.varName());
    }

    private void declareLocal(Local[] locals, Map<String, LlvmType> types, LocalVariable variable) {
        locals[variable.slot()] = new Local(STR."%\{variable.name()}", IrTypeMapper.mapType(variable.typeSymbol())
            .orElseThrow(() -> new IllegalArgumentException(STR."Unsupported type \{variable.typeSymbol().displayName()}")));

        var type = IrTypeMapper.mapType(variable.typeSymbol())
            .orElseThrow(() -> new IllegalArgumentException(STR."Local of type \{variable.typeSymbol()} is not supported"));
        if (type == LlvmType.Primitive.POINTER) {
            throw new IllegalArgumentException(STR."Locals of type \{variable.typeSymbol()} not yet supported");
        }
        types.put(STR."%\{variable.name().stringValue()}", new LlvmType.Pointer(type));
    }

    private void handleReturn(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ReturnInstruction instruction, UnnamedGenerator unnamed
    ) {
        if (instruction.opcode() != Opcode.RETURN) {
            if (types.get(stack.peekFirst()) instanceof LlvmType.Pointer p) {
                var varName = unnamed.generateNext();
                generator.load(varName, p.type(), LlvmType.Primitive.POINTER, stack.pop());
                stack.push(varName);
            }
        }

        // Plain return does not have a value
        if (instruction.opcode() != Opcode.RETURN) {
            generator.returnValue(stack.pop());
        } else {
            generator.returnVoid();
        }
    }

    private void handleStackInstruction(Deque<String> stack, StackInstruction instruction) {
        switch (instruction.opcode()) {
            case POP -> stack.pop();
            case DUP -> stack.push(stack.peekFirst());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} stack instruction not supported yet");
        }
    }

    private void handleStoreInstruction(IrCodeGenerator generator, Deque<String> stack, Local[] locals, Map<String, LlvmType> types, StoreInstruction instruction) {
        var reference = stack.pop();
        var index = switch (instruction.opcode()) {
            case ASTORE_0, DSTORE_0, FSTORE_0, ISTORE_0 -> 0;
            case ASTORE_1, DSTORE_1, FSTORE_1, ISTORE_1 -> 1;
            case ASTORE_2, DSTORE_2, FSTORE_2, ISTORE_2 -> 2;
            case ASTORE_3, DSTORE_3, FSTORE_3, ISTORE_3 -> 3;
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} store currently not supported");
        };
        var local = locals[index];
        // TODO: don't generate string
        if (types.get(local.varName()) instanceof LlvmType.Pointer p && generator.generate().contains(STR."\{local.varName()} = alloca")) {
            generator.store(p.type(), reference, p, local.varName());
        } else if (reference.startsWith("%")) {
            generator.bitcast(local.varName(), new LlvmType.Pointer(local.type()), reference, new LlvmType.Pointer(local.type()));
        } else {
            generator.alloca(local.varName(), local.type());
            generator.store(local.type(), reference, LlvmType.Primitive.POINTER, local.varName());
        }
    }
}
