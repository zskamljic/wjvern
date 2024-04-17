package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.ExceptionInfo;
import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.Vtable;

import java.lang.classfile.CompoundElement;
import java.lang.classfile.Label;
import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.instruction.ArrayStoreInstruction;
import java.lang.classfile.instruction.BranchInstruction;
import java.lang.classfile.instruction.ConstantInstruction;
import java.lang.classfile.instruction.ExceptionCatch;
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
import java.lang.classfile.instruction.ThrowInstruction;
import java.lang.reflect.AccessFlag;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class FunctionBuilder {
    private final MethodModel method;
    private final List<String> fieldDefinition;
    private final Set<String> varargs;
    private final Vtable vtable;
    private final boolean debug;
    private final String parent;

    public FunctionBuilder(MethodModel method, List<String> fieldNames, Set<String> varargs, Vtable vtable, boolean debug) {
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

        var codeGenerator = new IrMethodGenerator(
            returnType,
            name
        );
        if (!method.flags().has(AccessFlag.STATIC)) {
            codeGenerator.addParameter("this", new LlvmType.Pointer(new LlvmType.Declared(parent)));
        }
        method.code()
            .stream()
            .flatMap(CompoundElement::elementStream)
            .filter(LocalVariable.class::isInstance)
            .map(LocalVariable.class::cast)
            .skip(method.flags().has(AccessFlag.STATIC) ? 0 : 1)
            .limit(method.methodTypeSymbol().parameterCount())
            .forEach(lv -> {
                var paramType = IrTypeMapper.mapType(lv.typeSymbol());
                if (paramType instanceof LlvmType.Declared) {
                    paramType = new LlvmType.Pointer(paramType);
                }
                codeGenerator.addParameter(lv.name().stringValue(), paramType);
            });

        generateCode(codeGenerator);

        return codeGenerator.generate();
    }

    private void generateCode(IrMethodGenerator generator) {
        var optionalCode = method.code();
        if (optionalCode.isEmpty()) return;

        var code = optionalCode.get();
        var exceptions = new ArrayList<ExceptionInfo>();
        var activeExceptions = new ArrayList<ExceptionInfo>();
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
                case ExceptionCatch e -> handleExceptionCatch(labelGenerator, exceptions, e);
                case FieldInstruction f -> handleFieldInstruction(generator, stack, f);
                case IncrementInstruction i -> handleIncrement(generator, locals, i);
                case InvokeInstruction i -> {
                    handleInvoke(generator, stack, types, i);
                    if (i.opcode() == Opcode.INVOKESPECIAL && method.methodName().equalsString("<init>")) {
                        addInitVtable(generator);
                    }
                }
                case Label label -> {
                    var currentLabel = labelGenerator.getLabel(label);
                    exceptions.stream()
                        .filter(e -> e.getTryStart().equals(currentLabel))
                        .forEach(activeExceptions::add);
                    activeExceptions.removeIf(e -> e.getTryEnd().equals(currentLabel));

                    generator.label(currentLabel);

                    exceptions.stream()
                        .filter(e -> e.getCatchStart().equals(currentLabel))
                        .findFirst()
                        .map(ExceptionInfo::getVariable)
                        .ifPresent(stack::push);
                }
                case LineNumber l -> generator.comment(STR."Line \{l.line()}");
                case LoadInstruction l -> loadValue(stack, locals, l);
                case LocalVariable v ->
                    declareLocal(generator, locals, types, v.slot(), v.name().stringValue(), IrTypeMapper.mapType(v.typeSymbol()));
                case NewObjectInstruction n -> handleCreateNewObject(generator, stack, types, n);
                case NewPrimitiveArrayInstruction a -> handleCreatePrimitiveArray(generator, stack, types, a);
                case OperatorInstruction o -> handleOperatorInstruction(generator, stack, types, o);
                case ReturnInstruction r -> handleReturn(generator, stack, types, r);
                case StackInstruction s -> handleStackInstruction(stack, s);
                case StoreInstruction s -> handleStoreInstruction(generator, stack, locals, types, s);
                case ThrowInstruction _ -> handleThrowInstruction(generator, labelGenerator, types, activeExceptions, stack);
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

    private void addInitVtable(IrMethodGenerator generator) {
        var parentClass = new LlvmType.Declared(parent);
        var vtablePointer = generator.getElementPointer(parentClass, new LlvmType.Pointer(parentClass), "%this", "0");
        var vtableType = new LlvmType.Pointer(new LlvmType.Declared(STR."\{parent}_vtable_type"));
        var vtableTypePointer = new LlvmType.Pointer(vtableType);
        generator.store(vtableType, STR."@\{parent}_vtable_data", vtableTypePointer, vtablePointer);
    }

    private void handleArrayStore(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ArrayStoreInstruction instruction
    ) {
        var value = stack.pop();
        var index = stack.pop();
        var arrayReference = stack.pop();

        var varName = generator.getElementPointer(types.get(arrayReference), LlvmType.Primitive.POINTER, arrayReference, index);

        var type = IrTypeMapper.mapType(instruction.typeKind());
        value = loadPointerIfNeeded(generator, types, value);
        generator.store(type, value, LlvmType.Primitive.POINTER, varName);
    }

    private static String loadPointerIfNeeded(IrMethodGenerator generator, Map<String, LlvmType> types, String value) {
        if (types.get(value) instanceof LlvmType.Pointer p) {
            return generator.load(p.type(), p, value);
        }
        return value;
    }

    private void handleBranch(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, LabelGenerator labelGenerator, BranchInstruction instruction
    ) {
        switch (instruction.opcode()) {
            case GOTO -> generator.branchLabel(labelGenerator.getLabel(instruction.target()));
            case IF_ACMPNE -> {
                var b = stack.pop();
                var a = stack.pop();

                var varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.POINTER, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPGE -> {
                var b = loadIfNeeded(generator, types, stack.pop());
                var a = loadIfNeeded(generator, types, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFLE -> {
                var value = stack.pop();
                value = loadPointerIfNeeded(generator, types, value);

                var varName = generator.compare(IrMethodGenerator.Condition.LESS_EQUAL, LlvmType.Primitive.INT, value, "0");
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

    private String loadIfNeeded(IrMethodGenerator generator, Map<String, LlvmType> types, String name) {
        if (types.get(name) instanceof LlvmType.Pointer p) {
            return generator.load(p.type(), p, name);
        }
        return name;
    }

    private void handleCreateNewObject(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, NewObjectInstruction instruction
    ) {
        var varName = generator.alloca(new LlvmType.Declared(instruction.className().name().stringValue()));
        types.put(varName, new LlvmType.Pointer(new LlvmType.Declared(instruction.className().name().stringValue())));
        stack.push(varName);
    }

    private void handleCreatePrimitiveArray(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, NewPrimitiveArrayInstruction instruction
    ) {
        var type = IrTypeMapper.mapType(instruction.typeKind());

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
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, OperatorInstruction instruction
    ) {
        var operand2 = loadPointerIfNeeded(generator, types, stack.pop());
        var operand1 = loadPointerIfNeeded(generator, types, stack.pop());

        // TODO: parameterize by types
        var resultVar = switch (instruction.opcode()) {
            case DADD -> generator.binaryOperator(IrMethodGenerator.Operator.ADD, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DDIV -> generator.binaryOperator(IrMethodGenerator.Operator.DIV, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DMUL -> generator.binaryOperator(IrMethodGenerator.Operator.MUL, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case DSUB -> generator.binaryOperator(IrMethodGenerator.Operator.SUB, LlvmType.Primitive.DOUBLE, operand1, operand2);
            case FADD -> generator.binaryOperator(IrMethodGenerator.Operator.ADD, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FDIV -> generator.binaryOperator(IrMethodGenerator.Operator.DIV, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FMUL -> generator.binaryOperator(IrMethodGenerator.Operator.MUL, LlvmType.Primitive.FLOAT, operand1, operand2);
            case FSUB -> generator.binaryOperator(IrMethodGenerator.Operator.SUB, LlvmType.Primitive.FLOAT, operand1, operand2);
            case IADD -> generator.binaryOperator(IrMethodGenerator.Operator.ADD, LlvmType.Primitive.INT, operand1, operand2);
            case IDIV -> generator.binaryOperator(IrMethodGenerator.Operator.DIV, LlvmType.Primitive.INT, operand1, operand2);
            case IMUL -> generator.binaryOperator(IrMethodGenerator.Operator.MUL, LlvmType.Primitive.INT, operand1, operand2);
            case ISUB -> generator.binaryOperator(IrMethodGenerator.Operator.SUB, LlvmType.Primitive.INT, operand1, operand2);
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
            case LCONST_0 -> stack.push("0L");
            case LCONST_1 -> stack.push("1L");
            case LDC, LDC2_W -> stack.push(((ConstantInstruction.LoadConstantInstruction) instruction).constantEntry().constantValue().toString());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} constant is not supported yet");
        }
    }

    private void handleExceptionCatch(LabelGenerator labelGenerator, List<ExceptionInfo> exceptions, ExceptionCatch e) {
        exceptions.add(new ExceptionInfo(
            labelGenerator.getLabel(e.tryStart()),
            labelGenerator.getLabel(e.tryEnd()),
            labelGenerator.getLabel(e.handler()),
            e.catchType().map(ClassEntry::asSymbol).map(IrTypeMapper::mapType).orElse(null)
        ));
    }

    private void handleFieldInstruction(IrMethodGenerator generator, Deque<String> stack, FieldInstruction instruction) {
        if (instruction.opcode() == Opcode.GETFIELD) {

            var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol());

            var parentType = new LlvmType.Declared(instruction.field().owner().name().stringValue());
            var varName = generator.getElementPointer(
                parentType, new LlvmType.Pointer(parentType), stack.pop(),
                String.valueOf(fieldDefinition.indexOf(instruction.field().name().stringValue()) + 1)
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
                String.valueOf(fieldDefinition.indexOf(instruction.field().name().stringValue()) + 1)
            );
            generator.store(fieldType, value, new LlvmType.Pointer(fieldType), varName);
        } else {
            throw new IllegalArgumentException(STR."\{instruction.opcode()} field instruction is not yet supported");
        }
    }

    private void handleIncrement(IrMethodGenerator generator, Local[] locals, IncrementInstruction instruction) {
        var source = switch (instruction.opcode()) {
            case IINC -> locals[instruction.slot()];
            default -> throw new IllegalArgumentException(STR."Unsupported increment type \{instruction.opcode()}");
        };
        if (source.type() instanceof LlvmType.Pointer(LlvmType.Primitive p)) {
            var valueName = generator.load(p, source.type(), source.varName());
            var updatedName = generator.binaryOperator(IrMethodGenerator.Operator.ADD, p, valueName, String.valueOf(instruction.constant()));
            generator.store(p, updatedName, source.type(), source.varName());
        } else {
            throw new IllegalStateException("Local variable attempted to increment non-primitive");
        }
    }

    private void handleInvoke(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, InvokeInstruction invocation
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
            case INVOKEVIRTUAL -> handleInvokeVirtual(generator, invocation, types, parameters);
            case INVOKESTATIC -> invocation.method().name().stringValue();
            default -> throw new IllegalArgumentException(STR."\{invocation.opcode()} invocation not yet supported");
        };
        var returnVar = generator.call(returnType, functionName, parameters);

        if (returnVar != null) {
            stack.push(returnVar);
        }
    }

    private static String directCall(InvokeInstruction invocation) {
        return STR."\"\{invocation.method().owner().name()}_\{invocation.method().name()}\"";
    }

    private String handleInvokeVirtual(
        IrMethodGenerator generator, InvokeInstruction invocation, Map<String, LlvmType> types, List<Map.Entry<String, LlvmType>> parameters
    ) {
        if (!vtable.containsKey(invocation.name().stringValue(), invocation.typeSymbol())) return directCall(invocation);

        // Load vtable pointer
        var parentType = new LlvmType.Declared(parent);
        var vtablePointer = generator.getElementPointer(parentType, new LlvmType.Pointer(parentType), parameters.getFirst().getKey(), "0");

        // Get data from vtable pointer
        var vtableType = new LlvmType.Declared(STR."\{parent}_vtable_type");
        var vtableTypePointer = new LlvmType.Pointer(vtableType);
        var vtableData = generator.load(vtableTypePointer, new LlvmType.Pointer(vtableTypePointer), vtablePointer);

        // Get vtable pointer to function
        var vtableInfo = vtable.get(invocation.name().stringValue(), invocation.typeSymbol());
        var methodPointer = generator.getElementPointer(vtableType, vtableTypePointer, vtableData, String.valueOf(vtable.index(vtableInfo)));

        var function = vtableInfo.signature();
        var functionPointer = new LlvmType.Pointer(function);

        // Load function
        var functionName = generator.load(functionPointer, new LlvmType.Pointer(functionPointer), methodPointer);

        var actualType = parameters.getFirst().getValue();
        var expectedType = function.parameters().getFirst();
        if (!actualType.equals(expectedType)) {
            var parameter = parameters.removeFirst();
            var newParameter = generator.bitcast(parameter.getValue(), parameter.getKey(), expectedType);
            parameters.addFirst(Map.entry(newParameter, expectedType));
        }

        return functionName;
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
            case ALOAD_0, DLOAD_0, FLOAD_0, ILOAD_0, LLOAD_0 -> locals[0];
            case ALOAD_1, DLOAD_1, FLOAD_1, ILOAD_1, LLOAD_1 -> locals[1];
            case ALOAD_2, DLOAD_2, FLOAD_2, ILOAD_2, LLOAD_2 -> locals[2];
            case ALOAD_3, DLOAD_3, FLOAD_3, ILOAD_3, LLOAD_3 -> locals[3];
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} load is not supported yet");
        };
        stack.push(local.varName());
    }

    private void declareLocal(IrMethodGenerator generator, Local[] locals, Map<String, LlvmType> types, int slot, String name, LlvmType type) {
        var localName = STR."%\{name}";

        if (type == LlvmType.Primitive.POINTER) {
            throw new IllegalArgumentException(STR."Locals of type \{type} not yet supported");
        }
        LlvmType varType;
        if (type instanceof LlvmType.Pointer || generator.hasParameter(name)) {
            varType = type;
        } else {
            varType = new LlvmType.Pointer(type);
        }
        locals[slot] = new Local(localName, varType);
        types.put(localName, varType);
        if (!generator.hasParameter(name)) {
            generator.alloca(localName, type);
        }
    }

    private void handleReturn(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ReturnInstruction instruction
    ) {
        if (instruction.opcode() != Opcode.RETURN) {
            if (types.get(stack.peekFirst()) instanceof LlvmType.Pointer p) {
                var varName = generator.load(p.type(), p, stack.pop());
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

    private void handleStoreInstruction(
        IrMethodGenerator generator, Deque<String> stack, Local[] locals, Map<String, LlvmType> types, StoreInstruction instruction
    ) {
        var reference = stack.pop();
        var index = switch (instruction.opcode()) {
            case ASTORE_0, DSTORE_0, FSTORE_0, ISTORE_0, LSTORE_0 -> 0;
            case ASTORE_1, DSTORE_1, FSTORE_1, ISTORE_1, LSTORE_1 -> 1;
            case ASTORE_2, DSTORE_2, FSTORE_2, ISTORE_2, LSTORE_2 -> 2;
            case ASTORE_3, DSTORE_3, FSTORE_3, ISTORE_3, LSTORE_3 -> 3;
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} store currently not supported");
        };
        var local = locals[index];
        if (local == null) {
            var type = IrTypeMapper.mapType(instruction.typeKind());
            var localName = generator.alloca(type);
            if (!(type instanceof LlvmType.Pointer) && type != LlvmType.Primitive.POINTER) {
                type = new LlvmType.Pointer(type);
            }
            types.put(localName, type);
            local = new Local(localName, type);
            locals[index] = local;
        }

        var sourceType = types.get(reference);
        if (sourceType == null) {
            if (local.type() instanceof LlvmType.Pointer p) {
                if (p.type() instanceof LlvmType.Declared) {
                    sourceType = LlvmType.Primitive.POINTER;
                } else {
                    sourceType = p.type();
                }
            } else if (local.type() == LlvmType.Primitive.POINTER) {
                sourceType = local.type();
            } else {
                throw new IllegalStateException("Invalid type for store");
            }
        } else if (sourceType instanceof LlvmType.Pointer p) {
            sourceType = p.type();
            reference = generator.load(p.type(), p, reference);
        }
        generator.store(Objects.requireNonNullElse(sourceType, local.type()), reference, local.type(), local.varName());
    }

    private void handleThrowInstruction(
        IrMethodGenerator generator, LabelGenerator labelGenerator, HashMap<String, LlvmType> types, List<ExceptionInfo> active, Deque<String> stack
    ) {
        var exception = stack.pop();

        var exceptionType = types.get(exception);
        if (!(exceptionType instanceof LlvmType.Pointer(LlvmType.Declared(var typeName)))) {
            generator.call(LlvmType.Primitive.VOID, "__cxa_throw", List.of(
                Map.entry(exception, LlvmType.Primitive.POINTER),
                Map.entry("null", LlvmType.Primitive.POINTER),
                Map.entry("null", LlvmType.Primitive.POINTER)
            ));
            generator.unreachable();
            return;
        }
        var descriptorType = new LlvmType.Global(Utils.escape(STR."P\{typeName}_type_info"));

        var variable = generator.call(LlvmType.Primitive.POINTER, "__cxa_allocate_exception", List.of(Map.entry("8", LlvmType.Primitive.LONG)));
        generator.store(exceptionType, exception, LlvmType.Primitive.POINTER, variable);
        List<Map.Entry<String, LlvmType>> throwParameters = List.of(
            Map.entry(variable, types.get(exception)),
            Map.entry(descriptorType.toString(), LlvmType.Primitive.POINTER),
            Map.entry("null", LlvmType.Primitive.POINTER)
        );
        if (active.isEmpty()) {
            generator.call(LlvmType.Primitive.VOID, "__cxa_throw", throwParameters);
            generator.unreachable();
        } else {
            var next = labelGenerator.nextLabel();
            var selector = labelGenerator.nextLabel();
            generator.invoke(LlvmType.Primitive.VOID, "__cxa_throw", throwParameters, next, selector);
            generator.label(next);
            generator.unreachable();
            generator.label(selector);

            var landingPad = generator.landingPad(active.stream().map(ExceptionInfo::getExceptionTypeInfo).filter(Objects::nonNull).toList());
            var exceptionVar = generator.extractValue(landingPad, 0);
            var typeVar = generator.extractValue(landingPad, 1);
            for (var handler : active) {
                handler.setVariable(exceptionVar);
                if (handler.getExceptionTypeInfo() == null) continue;

                var typeId = generator.call(LlvmType.Primitive.INT, "llvm.eh.typeid.for",
                    List.of(Map.entry(handler.getExceptionTypeInfo().toString(), LlvmType.Primitive.POINTER)));
                var result = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.INT, typeVar, typeId);
                generator.branchBool(result, handler.getCatchStart(), "label3"); // FIXME: false should not be hardcoded
            }
        }
    }
}
