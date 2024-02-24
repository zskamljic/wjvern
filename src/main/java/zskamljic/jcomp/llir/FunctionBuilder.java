package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.VtableInfo;

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
import java.lang.constant.MethodTypeDesc;
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
    private final Map<MethodTypeDesc, VtableInfo> vtable;
    private final boolean debug;
    private final String parent;

    public FunctionBuilder(MethodModel method, List<String> fieldNames, Set<String> varargs, Map<MethodTypeDesc, VtableInfo> vtable, boolean debug) {
        this.method = method;
        this.fieldDefinition = fieldNames;
        this.varargs = varargs;
        this.vtable = vtable;
        this.debug = debug;
        this.parent = method.parent()
            .orElseThrow(() -> new IllegalArgumentException("Method must have a parent class"))
            .thisClass()
            .name()
            .stringValue();
    }

    public String generate() {
        var name = method.methodName().stringValue();
        if (!method.flags().has(AccessFlag.STATIC)) {
            name = STR."\{parent}_\{name}";
        }

        var returnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());

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

        if (method.methodName().equalsString("<init>")) {
            addInitVtable(generator);
        }

        var code = optionalCode.get();
        var locals = new Local[code.maxLocals()];
        var stack = new ArrayDeque<String>();
        var types = new HashMap<String, LlvmType>();
        var labelGenerator = new LabelGenerator();
        for (var element : code) {
            var line = STR."\{method.methodName()}: \{element}";
            switch (element) {
                case ArrayStoreInstruction as -> handleArrayStore(generator, stack, types, as);
                case BranchInstruction b -> handleBranch(generator, stack, types, labelGenerator, b);
                case ConstantInstruction c -> handleConstant(stack, c);
                case FieldInstruction f -> handleFieldInstruction(generator, stack, f);
                case IncrementInstruction i -> handleIncrement(generator, locals, i);
                case InvokeInstruction i -> handleInvoke(generator, stack, types, i);
                case Label label -> generator.label(labelGenerator.getLabel(label));
                case LineNumber l -> generator.comment(STR."Line \{l.line()}");
                case LoadInstruction l -> loadValue(stack, locals, l);
                case LocalVariable v -> declareLocal(locals, types, v);
                case NewObjectInstruction n -> handleCreateNewObject(generator, stack, types, n);
                case NewPrimitiveArrayInstruction a -> handleCreatePrimitiveArray(generator, stack, types, a);
                case OperatorInstruction o -> handleOperatorInstruction(generator, stack, types, o);
                case ReturnInstruction r -> handleReturn(generator, stack, types, r);
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

    private void addInitVtable(IrCodeGenerator generator) {
        if (vtable.isEmpty()) return; // No need, no virtual methods

        var parentClass = new LlvmType.Declared(parent);
        var vtablePointer = generator.getElementPointer(parentClass, new LlvmType.Pointer(parentClass), "%this", "0");
        var vtableType = new LlvmType.Pointer(new LlvmType.Declared(STR."\{parent}_vtable_type"));
        var vtableTypePointer = new LlvmType.Pointer(vtableType);
        generator.store(vtableType, STR."@\{parent}_vtable_data", vtableTypePointer, vtablePointer);
    }

    private void handleArrayStore(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ArrayStoreInstruction instruction
    ) {
        var value = stack.pop();
        var index = stack.pop();
        var arrayReference = stack.pop();

        var varName = generator.getElementPointer(types.get(arrayReference), LlvmType.Primitive.POINTER, arrayReference, index);

        var type = IrTypeMapper.mapType(instruction.typeKind())
            .orElseThrow(() -> new IllegalArgumentException(STR."\{instruction.typeKind()} in not a supported type for array store"));
        value = loadPointerIfNeeded(generator, types, value);
        generator.store(type, value, LlvmType.Primitive.POINTER, varName);
    }

    private static String loadPointerIfNeeded(IrCodeGenerator generator, Map<String, LlvmType> types, String value) {
        if (types.get(value) instanceof LlvmType.Pointer p) {
            return generator.load(p.type(), p, value);
        }
        return value;
    }

    private void handleBranch(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, LabelGenerator labelGenerator, BranchInstruction instruction
    ) {
        switch (instruction.opcode()) {
            case GOTO -> generator.branchLabel(labelGenerator.getLabel(instruction.target()));
            case IF_ICMPGE -> {
                var b = loadIfNeeded(generator, types, stack.pop());
                var a = loadIfNeeded(generator, types, stack.pop());

                var varName = generator.compare(IrCodeGenerator.Condition.GREATER_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFLE -> {
                var value = stack.pop();
                value = loadPointerIfNeeded(generator, types, value);

                var varName = generator.compare(IrCodeGenerator.Condition.LESS_EQUAL, LlvmType.Primitive.INT, value, "0");
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

    private String loadIfNeeded(IrCodeGenerator generator, Map<String, LlvmType> types, String name) {
        if (types.get(name) instanceof LlvmType.Pointer p) {
            return generator.load(p.type(), p, name);
        }
        return name;
    }

    private void handleCreateNewObject(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, NewObjectInstruction instruction
    ) {
        var varName = generator.alloca(new LlvmType.Declared(instruction.className().name().stringValue()));
        types.put(varName, new LlvmType.Pointer(new LlvmType.Declared(instruction.className().name().stringValue())));
        stack.push(varName);
    }

    private void handleCreatePrimitiveArray(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, NewPrimitiveArrayInstruction instruction
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
        var varName = generator.alloca(arrayType);
        stack.push(varName);
        types.put(varName, arrayType);
    }

    private void handleOperatorInstruction(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, OperatorInstruction instruction
    ) {
        var operand2 = loadPointerIfNeeded(generator, types, stack.pop());
        var operand1 = loadPointerIfNeeded(generator, types, stack.pop());

        // TODO: parameterize by type
        var resultVar = switch (instruction.opcode()) {
            case DADD -> generator.binaryOperator(IrCodeGenerator.Operator.ADD, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DDIV -> generator.binaryOperator(IrCodeGenerator.Operator.DIV, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DMUL -> generator.binaryOperator(IrCodeGenerator.Operator.MUL, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DSUB -> generator.binaryOperator(IrCodeGenerator.Operator.SUB, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case FADD -> generator.binaryOperator(IrCodeGenerator.Operator.ADD, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FDIV -> generator.binaryOperator(IrCodeGenerator.Operator.DIV, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FMUL -> generator.binaryOperator(IrCodeGenerator.Operator.MUL, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FSUB -> generator.binaryOperator(IrCodeGenerator.Operator.SUB, LlvmType.Primitive.FLOAT, operand1, operand2);
            case IADD -> generator.binaryOperator(IrCodeGenerator.Operator.ADD, LlvmType.Primitive.INT, operand1, operand2);
            case IDIV -> generator.binaryOperator(IrCodeGenerator.Operator.DIV, LlvmType.Primitive.INT, operand1, operand2);
            case IMUL -> generator.binaryOperator(IrCodeGenerator.Operator.MUL, LlvmType.Primitive.INT, operand1, operand2);
            case ISUB -> generator.binaryOperator(IrCodeGenerator.Operator.SUB, LlvmType.Primitive.INT, operand1, operand2);
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} is not supported yet");
        };

        stack.push(resultVar);
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

    private void handleFieldInstruction(IrCodeGenerator generator, Deque<String> stack, FieldInstruction instruction) {
        if (instruction.opcode() == Opcode.GETFIELD) {

            var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol());

            var parentType = new LlvmType.Declared(instruction.field().owner().name().stringValue());
            var varName = generator.getElementPointer(
                parentType, new LlvmType.Pointer(parentType), stack.pop(),
                String.valueOf(fieldDefinition.indexOf(instruction.field().name().stringValue()) + (vtable.isEmpty() ? 0 : 1))
            );

            var valueVar = generator.load(fieldType, new LlvmType.Pointer(fieldType), varName);
            stack.push(valueVar);
        } else if (instruction.opcode() == Opcode.PUTFIELD) {
            var value = stack.pop();
            var objectReference = stack.pop();

            var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol());

            var parentType = new LlvmType.Declared(instruction.field().owner().name().stringValue());
            var varName = generator.getElementPointer(
                parentType, new LlvmType.Pointer(parentType), objectReference,
                String.valueOf(fieldDefinition.indexOf(instruction.field().name().stringValue()) + (vtable.isEmpty() ? 0 : 1))
            );
            generator.store(fieldType, value, new LlvmType.Pointer(fieldType), varName);
        } else {
            throw new IllegalArgumentException(STR."\{instruction.opcode()} field instruction is not yet supported");
        }
    }

    private void handleIncrement(IrCodeGenerator generator, Local[] locals, IncrementInstruction instruction) {
        var source = switch (instruction.opcode()) {
            case IINC -> locals[instruction.slot()];
            default -> throw new IllegalArgumentException(STR."Unsupported increment type \{instruction.opcode()}");
        };
        var valueName = generator.load(source.type(), new LlvmType.Pointer(source.type()), source.varName());
        var updatedName = generator.binaryOperator(IrCodeGenerator.Operator.ADD, (LlvmType.Primitive) source.type(), valueName, String.valueOf(instruction.constant()));
        generator.store(source.type(), updatedName, new LlvmType.Pointer(source.type()), source.varName());
    }

    private void handleInvoke(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, InvokeInstruction invocation
    ) {
        var isVarArg = varargs.contains(invocation.method().name() + invocation.typeSymbol().descriptorString());

        var parameterCount = invocation.typeSymbol().parameterCount();
        if (isVarArg) {
            var parameter = stack.pop();
            if (types.get(parameter) instanceof LlvmType.Array array) {
                parameterCount = parameterCount - 1 + array.length();
                for (int i = 0; i < array.length(); i++) {
                    var pointerName = generator.getElementPointer(array, LlvmType.Primitive.POINTER, parameter, String.valueOf(i));
                    var varName = generator.load(array.type(), new LlvmType.Pointer(array.type()), pointerName);
                    switch (array.type()) {
                        case LlvmType.Primitive p when p == LlvmType.Primitive.FLOAT -> {
                            var extendedName = generator.floatingPointExtend(varName);
                            stack.push(extendedName);
                        }
                        case LlvmType.Primitive p when p == LlvmType.Primitive.BYTE || p == LlvmType.Primitive.SHORT -> {
                            var extendedName = generator.signedExtend(array.type(), "i32", varName);
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

            var irType = IrTypeMapper.mapType(type);
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

        var returnType = IrTypeMapper.mapType(invocation.typeSymbol().returnType());

        var functionName = switch (invocation.opcode()) {
            case INVOKESPECIAL -> directCall(invocation);
            case INVOKEVIRTUAL -> handleInvokeVirtual(generator, invocation, parameters);
            case INVOKESTATIC -> invocation.method().name().stringValue();
            default -> throw new IllegalArgumentException(STR."\{invocation.opcode()} invocation not yet supported");
        };
        var returnVar = generator.invoke(returnType, functionName, parameters);

        if (returnVar != null) {
            stack.push(returnVar);
        }
    }

    private static String directCall(InvokeInstruction invocation) {
        return STR."\"\{invocation.method().owner().name()}_\{invocation.method().name()}\"";
    }

    private String handleInvokeVirtual(IrCodeGenerator generator, InvokeInstruction invocation, ArrayList<Map.Entry<String, LlvmType>> parameters) {
        if (!vtable.containsKey(invocation.typeSymbol())) return directCall(invocation);

        // Load vtable pointer
        var parentType = new LlvmType.Declared(parent);
        var vtablePointer = generator.getElementPointer(parentType, new LlvmType.Pointer(parentType), parameters.getFirst().getKey(), "0");

        // Get data from vtable pointer
        var vtableType = new LlvmType.Declared(STR."\{parent}_vtable_type");
        var vtableTypePointer = new LlvmType.Pointer(vtableType);
        var vtableData = generator.load(vtableTypePointer, new LlvmType.Pointer(vtableTypePointer), vtablePointer);

        // Get vtable pointer to function
        var vtableInfo = vtable.get(invocation.typeSymbol());
        var methodPointer = generator.getElementPointer(vtableType, vtableTypePointer, vtableData, String.valueOf(vtableInfo.index()));

        // Load function
        return generator.load(vtableInfo.signature(), new LlvmType.Pointer(vtableInfo.signature()), methodPointer);
    }

    private LlvmType extendType(LlvmType type) {
        return switch (type) {
            case LlvmType.Primitive p when p == LlvmType.Primitive.FLOAT -> LlvmType.Primitive.DOUBLE;
            case LlvmType.Primitive p when p == LlvmType.Primitive.BYTE || p == LlvmType.Primitive.SHORT -> LlvmType.Primitive.INT;
            default -> type;
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
        locals[variable.slot()] = new Local(STR."%\{variable.name()}", IrTypeMapper.mapType(variable.typeSymbol()));

        var type = IrTypeMapper.mapType(variable.typeSymbol());
        if (type == LlvmType.Primitive.POINTER) {
            throw new IllegalArgumentException(STR."Locals of type \{variable.typeSymbol()} not yet supported");
        }
        types.put(STR."%\{variable.name().stringValue()}", new LlvmType.Pointer(type));
    }

    private void handleReturn(
        IrCodeGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ReturnInstruction instruction
    ) {
        if (instruction.opcode() != Opcode.RETURN) {
            if (types.get(stack.peekFirst()) instanceof LlvmType.Pointer p) {
                var varName = generator.load(p.type(), LlvmType.Primitive.POINTER, stack.pop());
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
