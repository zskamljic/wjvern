package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.ExceptionInfo;
import zskamljic.jcomp.llir.models.FunctionRegistry;
import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.Parameter;

import java.lang.classfile.CompoundElement;
import java.lang.classfile.Label;
import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.TypeKind;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.FieldRefEntry;
import java.lang.classfile.instruction.ArrayLoadInstruction;
import java.lang.classfile.instruction.ArrayStoreInstruction;
import java.lang.classfile.instruction.BranchInstruction;
import java.lang.classfile.instruction.ConstantInstruction;
import java.lang.classfile.instruction.ConvertInstruction;
import java.lang.classfile.instruction.ExceptionCatch;
import java.lang.classfile.instruction.FieldInstruction;
import java.lang.classfile.instruction.IncrementInstruction;
import java.lang.classfile.instruction.InvokeInstruction;
import java.lang.classfile.instruction.LineNumber;
import java.lang.classfile.instruction.LoadInstruction;
import java.lang.classfile.instruction.LocalVariable;
import java.lang.classfile.instruction.NewObjectInstruction;
import java.lang.classfile.instruction.NewPrimitiveArrayInstruction;
import java.lang.classfile.instruction.NewReferenceArrayInstruction;
import java.lang.classfile.instruction.OperatorInstruction;
import java.lang.classfile.instruction.ReturnInstruction;
import java.lang.classfile.instruction.StackInstruction;
import java.lang.classfile.instruction.StoreInstruction;
import java.lang.classfile.instruction.TableSwitchInstruction;
import java.lang.classfile.instruction.ThrowInstruction;
import java.lang.constant.ClassDesc;
import java.lang.reflect.AccessFlag;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Deque;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class FunctionBuilder {
    private static final LlvmType.Declared ARRAY_TYPE = new LlvmType.Declared("java_Array");
    private static final LlvmType.Pointer ARRAY_POINTER_TYPE = new LlvmType.Pointer(ARRAY_TYPE);

    private final MethodModel method;
    private final List<String> fieldDefinition;
    private final FunctionRegistry functionRegistry;
    private final boolean debug;
    private final String parent;

    public FunctionBuilder(
        MethodModel method,
        List<String> fieldNames,
        FunctionRegistry functionRegistry,
        boolean debug
    ) {
        this.method = method;
        this.fieldDefinition = fieldNames;
        this.functionRegistry = functionRegistry;
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
            name = Utils.methodName(parent, method);
        }

        var actualReturnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
        var returnType = actualReturnType;
        if (returnType instanceof LlvmType.Declared) {
            returnType = LlvmType.Primitive.VOID;
        }

        var codeGenerator = new IrMethodGenerator(returnType, name);
        var labels = method.code()
            .stream()
            .flatMap(CompoundElement::elementStream)
            .filter(Label.class::isInstance)
            .map(Label.class::cast)
            .toList();
        var parameterCandidates = method.code()
            .stream()
            .flatMap(CompoundElement::elementStream)
            .filter(LocalVariable.class::isInstance)
            .map(LocalVariable.class::cast)
            .filter(v -> labels.getFirst().equals(v.startScope()) && labels.getLast().equals(v.endScope()))
            .sorted(Comparator.comparing(LocalVariable::slot))
            .toList();

        var parameterCount = method.methodTypeSymbol().parameterCount();
        if (!method.flags().has(AccessFlag.STATIC)) {
            parameterCount++;
            if (parameterCandidates.isEmpty()) {
                parameterCandidates = List.of(
                    LocalVariable.of(0, "this", ClassDesc.of("java.lang.Object"), null, null)
                );
            }
        }

        if (actualReturnType instanceof LlvmType.Declared) {
            codeGenerator.addReturnParameter(actualReturnType);
        }

        for (int i = 0; i < parameterCount; i++) {
            var parameter = parameterCandidates.get(i);
            var paramType = IrTypeMapper.mapType(parameter.typeSymbol());
            if (paramType instanceof LlvmType.Declared) {
                paramType = new LlvmType.Pointer(paramType);
            }
            codeGenerator.addParameter(STR."local.\{i}", paramType);
        }

        generateCode(codeGenerator);

        return codeGenerator.generate();
    }

    private void generateCode(IrMethodGenerator generator) {
        var optionalCode = method.code();
        if (optionalCode.isEmpty()) return;

        var code = optionalCode.get();
        var stack = new ArrayDeque<String>();
        var types = new HashMap<String, LlvmType>();
        var exceptionState = new ExceptionState();
        var labelGenerator = new LabelGenerator();
        var locals = new Locals(generator, types, labelGenerator, generator::hasParameter);
        var switchStates = new SwitchStates(generator, types);
        String currentLabel = null;
        for (var element : code) {
            switch (element) {
                case ArrayStoreInstruction as -> handleArrayStore(generator, stack, types, locals, as);
                case ArrayLoadInstruction al -> handleArrayLoad(generator, stack, types, locals, al);
                case BranchInstruction b -> handleBranch(generator, stack, types, locals, labelGenerator, switchStates, currentLabel, b);
                case ConstantInstruction c -> handleConstant(stack, c);
                case ConvertInstruction c -> handleConvertInstruction(generator, stack, types, locals, c);
                case ExceptionCatch e -> handleExceptionCatch(generator, labelGenerator, exceptionState, e);
                case FieldInstruction f -> handleFieldInstruction(generator, stack, types, locals, f);
                case IncrementInstruction i -> handleIncrement(generator, locals, types, i);
                case InvokeInstruction i -> {
                    handleInvoke(generator, stack, types, locals, labelGenerator, exceptionState, i);
                    if (i.opcode() == Opcode.INVOKESPECIAL && method.methodName().equalsString("<init>")) {
                        addInitVtable(generator);
                    }
                }
                case Label label ->
                    currentLabel = handleLabel(generator, labelGenerator, exceptionState, currentLabel, locals, stack, switchStates, label);
                case LineNumber l -> generator.comment(STR."Line \{l.line()}");
                case LoadInstruction l -> loadValue(stack, locals, l);
                case LocalVariable v -> locals.register(v);
                case NewObjectInstruction n -> handleCreateNewObject(generator, stack, types, n);
                case NewPrimitiveArrayInstruction a -> handleCreatePrimitiveArray(generator, stack, types, locals, a);
                case NewReferenceArrayInstruction a -> handleCreateRefArray(generator, stack, types, locals, a);
                case OperatorInstruction o -> handleOperatorInstruction(generator, stack, labelGenerator, types, locals, o);
                case ReturnInstruction r -> handleReturn(generator, stack, types, r);
                case StackInstruction s -> handleStackInstruction(stack, s);
                case StoreInstruction s -> handleStoreInstruction(generator, stack, locals, types, s);
                case TableSwitchInstruction s -> handleSwitch(generator, stack, labelGenerator, switchStates, s);
                case ThrowInstruction _ -> handleThrowInstruction(generator, labelGenerator, types, exceptionState, stack);
                default -> {
                    if (debug) System.out.println(STR."\{method.methodName()}: \{element}: not handled");
                }
            }
        }
        if (debug && !stack.isEmpty()) {
            System.out.println("Remaining on stack: ");
            while (!stack.isEmpty()) {
                System.out.println(stack.pop());
            }
        }
    }

    private void generateLandingPad(IrMethodGenerator generator, LabelGenerator labelGenerator, ExceptionState exceptions) {
        var dispatcherLabel = labelGenerator.nextLabel();
        generator.label(dispatcherLabel);
        var landingPad = generator.landingPad(exceptions.getActiveTypes());
        var exceptionVar = generator.extractValue(landingPad, 0);
        generator.store(LlvmType.Primitive.POINTER, exceptionVar, LlvmType.Primitive.POINTER, exceptions.getExceptionVariable());
        var typeVar = generator.extractValue(landingPad, 1);
        var nullHandler = exceptions.getDefaultHandler();
        var defaultCatchLabel = nullHandler.map(ExceptionInfo::catchStart)
            .orElseGet(labelGenerator::nextLabel);
        exceptions.saveDispatcher(dispatcherLabel);

        for (var handler : exceptions.getActive()) {
            var typeId = generator.call(LlvmType.Primitive.INT, "llvm.eh.typeid.for",
                List.of(new Parameter(handler.typeInfo().toString(), LlvmType.Primitive.POINTER)));
            var result = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.INT, typeVar, typeId);
            generator.branchBool(result, handler.catchStart(), defaultCatchLabel);
        }

        if (nullHandler.isEmpty()) {
            var defaultDispatcher = exceptions.getDefaultDispatcher(labelGenerator::nextLabel);
            generator.label(defaultDispatcher);
            var cleanupPad = generator.landingPad(null);
            var exception = generator.extractValue(cleanupPad, 0);
            generator.store(LlvmType.Primitive.POINTER, exception, LlvmType.Primitive.POINTER, exceptions.getExceptionVariable());
            generator.label(defaultCatchLabel);
            generator.call(LlvmType.Primitive.VOID, "__cxa_throw", List.of(new Parameter(exceptions.getExceptionVariable(), LlvmType.Primitive.POINTER))); // TODO: parameters from throw
            generator.unreachable();
        }
    }

    private void addInitVtable(IrMethodGenerator generator) {
        var parentClass = new LlvmType.Declared(parent);
        var vtablePointer = generator.getElementPointer(parentClass, new LlvmType.Pointer(parentClass), "%local.0", List.of("0", "0"));
        var vtableType = new LlvmType.Pointer(new LlvmType.Declared(STR."\{parent}_vtable_type"));
        var vtableTypePointer = new LlvmType.Pointer(vtableType);
        generator.store(vtableType, STR."@\{parent}_vtable_data", vtableTypePointer, vtablePointer);
    }

    private void handleArrayStore(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, Locals locals, ArrayStoreInstruction instruction
    ) {
        var value = stack.pop();
        var index = stack.pop();
        var arrayReference = loadIfNeeded(generator, types, locals, stack.pop());

        var arrayType = types.get(arrayReference);

        LlvmType componentType;
        switch (arrayType) {
            case LlvmType.Pointer(LlvmType.Array array) -> {
                arrayType = array;
                componentType = array.type();
            }
            case LlvmType.Array array -> componentType = array.type();
            case LlvmType.Pointer(LlvmType.SizedArray array) -> {
                arrayType = array;
                componentType = array.type();
            }
            case LlvmType.SizedArray array -> componentType = array.type();
            default -> {
                System.err.println(STR."Unknown array type: \{arrayType}");
                componentType = LlvmType.Primitive.POINTER;
            }
        }
        var pointer = generator.getElementPointer(arrayType, new LlvmType.Pointer(arrayType), arrayReference, List.of("0", "1"));
        var actualArray = generator.load(LlvmType.Primitive.POINTER, LlvmType.Primitive.POINTER, pointer);
        index = loadIfNeeded(generator, types, locals, index);
        var varName = generator.getElementPointer(componentType, LlvmType.Primitive.POINTER, actualArray, index);

        if (!(types.get(value) instanceof LlvmType.Pointer(LlvmType.Declared _))) {
            value = loadIfNeeded(generator, types, locals, value);
        }
        var type = types.getOrDefault(value, IrTypeMapper.mapType(instruction.typeKind()));
        generator.store(type, value, LlvmType.Primitive.POINTER, varName);
    }

    private void handleArrayLoad(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, Locals locals, ArrayLoadInstruction instruction
    ) {
        var index = loadIfNeeded(generator, types, locals, stack.pop());
        var reference = loadIfNeeded(generator, types, locals, stack.pop());

        var arrayPointer = generator.getElementPointer(ARRAY_TYPE, ARRAY_POINTER_TYPE, reference, List.of("0", "1"));
        var array = generator.load(LlvmType.Primitive.POINTER, LlvmType.Primitive.POINTER, arrayPointer);

        var type = switch (types.get(reference)) {
            case LlvmType.Array a -> a.type();
            case LlvmType.SizedArray a -> a.type();
            case LlvmType.Pointer(LlvmType.Array a) -> a.type();
            case LlvmType.Pointer(LlvmType.SizedArray a) -> a.type();
            default -> {
                var instructionType = IrTypeMapper.mapType(instruction.typeKind());
                if (instructionType == LlvmType.Primitive.POINTER) {
                    throw new IllegalStateException(STR."Invalid reference type \{reference}: \{types.get(reference)}");
                }
                yield instructionType;
            }
        };

        var indexPointer = generator.getElementPointer(type, LlvmType.Primitive.POINTER, array, index);
        if (instruction.typeKind() == TypeKind.ReferenceType) {
            type = new LlvmType.Pointer(type);
        }
        var value = generator.load(type, LlvmType.Primitive.POINTER, indexPointer);
        stack.push(value);
    }

    private void handleBranch(
        IrMethodGenerator generator,
        Deque<String> stack,
        Map<String, LlvmType> types,
        Locals locals,
        LabelGenerator labelGenerator,
        SwitchStates switchStates,
        String currentLabel,
        BranchInstruction instruction
    ) {
        switch (instruction.opcode()) {
            case GOTO -> {
                switchStates.changedLabel(currentLabel, stack);
                generator.branchLabel(labelGenerator.getLabel(instruction.target()));
            }
            case IF_ACMPEQ -> {
                var b = stack.pop();
                var a = stack.pop();

                var varName = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.POINTER, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ACMPNE -> {
                var b = stack.pop();
                var a = stack.pop();

                var varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.POINTER, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPEQ -> {
                var b = loadIfNeeded(generator, types, locals, stack.pop());
                var a = loadIfNeeded(generator, types, locals, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPNE -> {
                var b = loadIfNeeded(generator, types, locals, stack.pop());
                var a = loadIfNeeded(generator, types, locals, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPLE -> {
                var b = loadIfNeeded(generator, types, locals, stack.pop());
                var a = loadIfNeeded(generator, types, locals, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.LESS_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPLT -> {
                var b = loadIfNeeded(generator, types, locals, stack.pop());
                var a = loadIfNeeded(generator, types, locals, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.LESS, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPGE -> {
                var b = loadIfNeeded(generator, types, locals, stack.pop());
                var a = loadIfNeeded(generator, types, locals, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPGT -> {
                var b = loadIfNeeded(generator, types, locals, stack.pop());
                var a = loadIfNeeded(generator, types, locals, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFLE -> {
                var value = stack.pop();
                value = loadIfNeeded(generator, types, locals, value);

                var varName = generator.compare(IrMethodGenerator.Condition.LESS_EQUAL, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFLT -> {
                var value = stack.pop();
                value = loadIfNeeded(generator, types, locals, value);

                var varName = generator.compare(IrMethodGenerator.Condition.LESS, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFGE -> {
                var value = stack.pop();
                value = loadIfNeeded(generator, types, locals, value);

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER_EQUAL, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFGT -> {
                var value = stack.pop();
                value = loadIfNeeded(generator, types, locals, value);

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFEQ -> {
                var value = loadIfNeeded(generator, types, locals, stack.pop());

                String varName;
                if (types.get(value) != LlvmType.Primitive.BOOLEAN) {
                    varName = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.INT, value, "0");
                } else {
                    varName = value;
                }
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFNE -> {
                var value = loadIfNeeded(generator, types, locals, stack.pop());

                String varName;
                if (types.get(value) != LlvmType.Primitive.BOOLEAN) {
                    varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.INT, value, "0");
                } else {
                    varName = value;
                }
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFNONNULL -> {
                var value = loadIfNeeded(generator, types, locals, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.POINTER, value, "null");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFNULL -> {
                var value = loadIfNeeded(generator, types, locals, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.POINTER, value, "null");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = STR."not_\{ifTrue}";
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} jump not supported yet");
        }
    }

    private String loadIfNeeded(IrMethodGenerator generator, Map<String, LlvmType> types, Locals locals, String value) {
        var type = types.get(value);
        if (!(type instanceof LlvmType.Pointer(LlvmType.Declared _)) &&
            type instanceof LlvmType.Pointer p &&
            !generator.hasParameter(value.substring(1))) {
            var loadedType = p.type();
            if (locals.contains(value) && (p.type() instanceof LlvmType.Array)) {
                loadedType = new LlvmType.Pointer(p.type());
            }
            var name = generator.load(loadedType, p, value);
            types.put(name, loadedType);
            return name;
        }
        return value;
    }

    private void handleCreateNewObject(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, NewObjectInstruction instruction
    ) {
        var varName = generator.alloca(new LlvmType.Declared(instruction.className().name().stringValue()));
        types.put(varName, new LlvmType.Pointer(new LlvmType.Declared(instruction.className().name().stringValue())));
        stack.push(varName);
    }

    private void handleCreatePrimitiveArray(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, Locals locals, NewPrimitiveArrayInstruction instruction
    ) {
        var type = IrTypeMapper.mapType(instruction.typeKind());
        var sizeVariable = stack.peek();
        var content = handleCreateArray(generator, stack, types, locals, type);

        String arrayLength;
        if (sizeVariable != null && sizeVariable.matches("\\d+")) {
            var size = switch (type) {
                case BYTE -> 1;
                case LONG -> 8;
                default -> 4;
            };
            arrayLength = String.valueOf(Integer.parseInt(sizeVariable) * size); // TODO: determine size based on type
        } else {
            var arraySize = loadIfNeeded(generator, types, locals, sizeVariable);
            arrayLength = generator.binaryOperator(IrMethodGenerator.Operator.MUL, LlvmType.Primitive.INT, arraySize, "4");
        }

        if (type.isFloatingPoint()) {
            if (type == LlvmType.Primitive.FLOAT) {
                type = LlvmType.Primitive.INT;
            } else {
                type = LlvmType.Primitive.LONG;
            }
        }

        generator.call(LlvmType.Primitive.VOID, STR."llvm.memset.p0.\{type}", List.of(
            new Parameter(content, LlvmType.Primitive.POINTER),
            new Parameter("0", LlvmType.Primitive.BYTE),
            new Parameter(arrayLength, LlvmType.Primitive.LONG),
            new Parameter("false", LlvmType.Primitive.BOOLEAN)
        ));
    }

    private void handleCreateRefArray(
        IrMethodGenerator generator, ArrayDeque<String> stack, HashMap<String, LlvmType> types, Locals locals, NewReferenceArrayInstruction instruction
    ) {
        var type = IrTypeMapper.mapType(instruction.componentType().asSymbol());
        handleCreateArray(generator, stack, types, locals, type);
    }

    private String handleCreateArray(IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, Locals locals, LlvmType type) {
        var size = stack.pop();
        LlvmType arrayType;
        if (size.matches("\\d+")) {
            arrayType = new LlvmType.SizedArray(Integer.parseInt(size), type);
        } else {
            arrayType = new LlvmType.Array(type);
        }
        var arrayPointer = new LlvmType.Pointer(arrayType);
        var varName = generator.alloca(arrayType);
        var length = generator.getElementPointer(arrayType, arrayPointer, varName, List.of("0", "0"));
        generator.store(LlvmType.Primitive.INT, size, new LlvmType.Pointer(LlvmType.Primitive.INT), length);
        var content = generator.alloca(type, loadIfNeeded(generator, types, locals, size));
        var contentPointer = generator.getElementPointer(arrayType, arrayPointer, varName, List.of("0", "1"));
        generator.store(LlvmType.Primitive.POINTER, content, LlvmType.Primitive.POINTER, contentPointer);
        stack.push(varName);
        types.put(varName, arrayType);

        return content;
    }

    private void handleOperatorInstruction(
        IrMethodGenerator generator, Deque<String> stack, LabelGenerator labelGenerator, Map<String, LlvmType> types, Locals locals, OperatorInstruction instruction
    ) {
        var operand = loadIfNeeded(generator, types, locals, stack.pop());

        var type = IrTypeMapper.mapType(instruction.opcode().primaryTypeKind());
        var resultVar = switch (instruction.opcode()) {
            case ARRAYLENGTH -> {
                var arrayType = new LlvmType.Declared("java_Array");
                var arrayPointer = new LlvmType.Pointer(arrayType);
                var pointer = generator.getElementPointer(arrayType, arrayPointer, operand, List.of("0", "0"));
                yield generator.load(LlvmType.Primitive.INT, LlvmType.Primitive.POINTER, pointer);
            }
            case DADD, FADD, IADD, LADD ->
                generator.binaryOperator(IrMethodGenerator.Operator.ADD, type, loadIfNeeded(generator, types, locals, stack.pop()), operand);
            case DDIV, FDIV, IDIV, LDIV ->
                generator.binaryOperator(IrMethodGenerator.Operator.DIV, type, loadIfNeeded(generator, types, locals, stack.pop()), operand);
            case DMUL, FMUL, IMUL, LMUL ->
                generator.binaryOperator(IrMethodGenerator.Operator.MUL, type, loadIfNeeded(generator, types, locals, stack.pop()), operand);
            case DSUB, FSUB, ISUB, LSUB ->
                generator.binaryOperator(IrMethodGenerator.Operator.SUB, type, loadIfNeeded(generator, types, locals, stack.pop()), operand);
            case IAND -> generator.binaryOperator(IrMethodGenerator.Operator.AND, type, loadIfNeeded(generator, types, locals, stack.pop()), operand);
            case ISHR ->
                generator.binaryOperator(IrMethodGenerator.Operator.ASHR, type, loadIfNeeded(generator, types, locals, stack.pop()), operand);
            case LCMP -> signCompare(generator, labelGenerator, types, loadIfNeeded(generator, types, locals, stack.pop()), operand);
            case LOR -> generator.binaryOperator(IrMethodGenerator.Operator.OR, type, loadIfNeeded(generator, types, locals, stack.pop()), operand);
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} is not supported yet");
        };

        stack.push(resultVar);
    }

    private static String signCompare(
        IrMethodGenerator generator, LabelGenerator labelGenerator, Map<String, LlvmType> types, String operand1, String operand2
    ) {
        // TODO: replace by scmp when available
        var result = generator.alloca(LlvmType.Primitive.INT);
        types.put(result, new LlvmType.Pointer(LlvmType.Primitive.INT));

        var end = labelGenerator.nextLabel();
        sideComparison(generator, labelGenerator, IrMethodGenerator.Condition.LESS, operand1, operand2, result, "-1", end);
        sideComparison(generator, labelGenerator, IrMethodGenerator.Condition.GREATER, operand1, operand2, result, "1", end);

        generator.store(LlvmType.Primitive.INT, "0", new LlvmType.Pointer(LlvmType.Primitive.INT), result);
        generator.branchLabel(end);
        generator.label(end);

        return result;
    }

    private static void sideComparison(
        IrMethodGenerator generator,
        LabelGenerator labelGenerator,
        IrMethodGenerator.Condition condition,
        String operand1,
        String operand2,
        String varName,
        String value,
        String endLabel
    ) {
        var result = generator.compare(condition, LlvmType.Primitive.LONG, operand1, operand2);
        var resultTrue = labelGenerator.nextLabel();
        var resultFalse = labelGenerator.nextLabel();
        generator.branchBool(result, resultTrue, resultFalse);
        generator.label(resultTrue);
        generator.store(LlvmType.Primitive.INT, value, new LlvmType.Pointer(LlvmType.Primitive.INT), varName);
        generator.branchLabel(endLabel);
        generator.label(resultFalse);
    }

    private void handleConstant(Deque<String> stack, ConstantInstruction instruction) {
        switch (instruction.opcode()) {
            case ACONST_NULL -> stack.push("null");
            case BIPUSH, SIPUSH -> stack.push(instruction.constantValue().toString());
            case ICONST_M1 -> stack.push("-1");
            case ICONST_0, LCONST_0 -> stack.push("0");
            case ICONST_1, LCONST_1 -> stack.push("1");
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

    private void handleConvertInstruction(IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, Locals locals, ConvertInstruction c) {
        var sourceType = IrTypeMapper.mapType(c.fromType());
        var targetType = IrTypeMapper.mapType(c.toType());

        var source = loadIfNeeded(generator, types, locals, stack.pop());
        var result = switch (c.opcode()) {
            case D2F -> generator.floatingPointTruncate(sourceType, source, targetType);
            case D2I, D2L, F2I, F2L -> generator.floatingPointToSignedInteger(sourceType, source, targetType);
            case F2D -> generator.floatingPointExtend(source);
            case I2D, I2F, L2F, L2D -> generator.signedToFloatingPoint(sourceType, source, targetType);
            case I2B, I2C, I2S, L2I -> generator.signedTruncate(sourceType, source, targetType);
            case I2L -> generator.signedExtend(sourceType, source, targetType);
            default -> throw new UnsupportedOperationException(STR."Conversion for \{c.opcode()} is not yet supported");
        };
        types.put(result, targetType);
        stack.push(result);
    }

    private void handleExceptionCatch(IrMethodGenerator generator, LabelGenerator labelGenerator, ExceptionState exceptions, ExceptionCatch e) {
        exceptions.add(ExceptionInfo.create(
            labelGenerator.getLabel(e.tryStart()),
            labelGenerator.getLabel(e.tryEnd()),
            labelGenerator.getLabel(e.handler()),
            e.catchType().map(ClassEntry::asSymbol).map(IrTypeMapper::mapType).orElse(null)
        ));
        if (exceptions.shouldGenerateVariables()) {
            var exception = generator.alloca(LlvmType.Primitive.POINTER);
            exceptions.setExceptionVariable(exception);
        }
    }

    private void handleFieldInstruction(IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, Locals locals, FieldInstruction instruction) {
        switch (instruction.opcode()) {
            case GETFIELD -> getField(generator, types, locals, stack, instruction.field());
            case PUTFIELD -> putField(generator, stack, instruction);
            case GETSTATIC -> getStatic(generator, types, stack, instruction.field());
            case PUTSTATIC -> putStatic(generator, types, locals, stack, instruction.field());
            default -> throw new IllegalArgumentException(STR."\{instruction.opcode()} field instruction is not yet supported");
        }
    }

    private void getField(IrMethodGenerator generator, Map<String, LlvmType> types, Locals locals, Deque<String> stack, FieldRefEntry field) {
        var fieldType = IrTypeMapper.mapType(field.typeSymbol());

        var source = loadIfNeeded(generator, types, locals, stack.pop());
        var parentType = new LlvmType.Declared(field.owner().name().stringValue());
        var varName = generator.getElementPointer(
            parentType, new LlvmType.Pointer(parentType), source,
            List.of("0", String.valueOf(fieldDefinition.indexOf(field.name().stringValue()) + 1))
        );

        var valueVar = generator.load(fieldType, new LlvmType.Pointer(fieldType), varName);
        types.put(valueVar, fieldType);
        stack.push(valueVar);
    }

    private void putField(IrMethodGenerator generator, Deque<String> stack, FieldInstruction instruction) {
        var value = stack.pop();
        var objectReference = stack.pop();

        var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol());

        var parentType = new LlvmType.Declared(instruction.field().owner().name().stringValue());
        var varName = generator.getElementPointer(
            parentType, new LlvmType.Pointer(parentType), objectReference,
            List.of("0", String.valueOf(fieldDefinition.indexOf(instruction.field().name().stringValue()) + 1))
        );
        generator.store(fieldType, value, new LlvmType.Pointer(fieldType), varName);
    }

    private void getStatic(IrMethodGenerator generator, Map<String, LlvmType> types, Deque<String> stack, FieldRefEntry field) {
        var staticField = Utils.staticVariableName(field);
        var type = IrTypeMapper.mapType(field.typeSymbol());
        var loaded = generator.load(type, new LlvmType.Pointer(type), staticField);
        types.put(loaded, type);
        stack.push(loaded);
    }

    private void putStatic(IrMethodGenerator generator, Map<String, LlvmType> types, Locals locals, Deque<String> stack, FieldRefEntry field) {
        var value = loadIfNeeded(generator, types, locals, stack.pop());

        var type = IrTypeMapper.mapType(field.typeSymbol());
        var staticField = Utils.staticVariableName(field);
        generator.store(type, value, new LlvmType.Pointer(type), staticField);
    }

    private void handleIncrement(IrMethodGenerator generator, Locals locals, HashMap<String, LlvmType> types, IncrementInstruction instruction) {
        var source = locals.get(instruction.slot());
        if (source.type() instanceof LlvmType.Primitive p && p != LlvmType.Primitive.POINTER) {
            var valueName = generator.load(p, new LlvmType.Pointer(source.type()), source.varName());
            var updatedName = generator.binaryOperator(IrMethodGenerator.Operator.ADD, p, valueName, String.valueOf(instruction.constant()));
            generator.store(p, updatedName, new LlvmType.Pointer(source.type()), source.varName());
        } else if (types.get(source.varName()) instanceof LlvmType.Pointer(LlvmType.Primitive p)) {
            var valueName = generator.load(p, new LlvmType.Pointer(p), source.varName());
            var updatedName = generator.binaryOperator(IrMethodGenerator.Operator.ADD, p, valueName, String.valueOf(instruction.constant()));
            generator.store(p, updatedName, new LlvmType.Pointer(p), source.varName());
        } else {
            throw new IllegalStateException("Local variable attempted to increment non-primitive");
        }
    }

    private void handleInvoke(
        IrMethodGenerator generator,
        Deque<String> stack,
        Map<String, LlvmType> types,
        Locals locals,
        LabelGenerator labelGenerator,
        ExceptionState exceptions,
        InvokeInstruction invocation
    ) {
        var isVarArg = functionRegistry.isNativeVarArg(invocation.method().owner().name().stringValue(), invocation.method());

        var parameterCount = invocation.typeSymbol().parameterCount();
        if (isVarArg) {
            parameterCount = prepareVarArgParameters(generator, stack, types, parameterCount);
        }

        var parameters = new ArrayList<Parameter>();
        // Parameters are on stack, reverse order
        for (int i = parameterCount - 1; i >= 0; i--) {
            var type = invocation.typeSymbol().parameterType(Math.min(i, invocation.typeSymbol().parameterCount()));
            var targetType = IrTypeMapper.mapType(type);
            if (targetType instanceof LlvmType.Declared) {
                targetType = new LlvmType.Pointer(targetType);
            }

            var variable = loadIfNeeded(generator, types, locals, stack.pop());
            var actualType = types.getOrDefault(variable, targetType);

            if (functionRegistry.isNative(invocation.owner().name().stringValue(), invocation.method()) &&
                arrayNestedType(actualType) instanceof LlvmType nestedType) {
                var dataPointer = generator.getElementPointer(ARRAY_TYPE, ARRAY_POINTER_TYPE, variable, List.of("0", "1"));
                variable = generator.load(LlvmType.Primitive.POINTER, LlvmType.Primitive.POINTER, dataPointer);
                actualType = new LlvmType.Pointer(nestedType);
            }

            parameters.addFirst(new Parameter(variable, actualType));
        }

        // Add implicit this
        if (invocation.opcode() != Opcode.INVOKESTATIC) {
            var typeName = Utils.escape(invocation.method().owner().name().stringValue());
            var thisParameter = loadIfNeeded(generator, types, locals, stack.pop());
            parameters.addFirst(new Parameter(thisParameter, new LlvmType.Pointer(new LlvmType.Declared(typeName))));
        }

        var returnType = IrTypeMapper.mapType(invocation.typeSymbol().returnType());
        if (returnType instanceof LlvmType.Declared) {
            var retValue = generator.alloca(returnType);
            types.put(retValue, new LlvmType.Pointer(returnType));
            parameters.addFirst(new Parameter(retValue, returnType, true));
            stack.push(retValue);
            returnType = LlvmType.Primitive.VOID;
        }
        if (isVarArg) {
            returnType = new LlvmType.NativeVarArgReturn(returnType, parameters.stream()
                .limit(invocation.typeSymbol().parameterCount() - 1)
                .map(Parameter::type)
                .toList());
        }

        var functionName = switch (invocation.opcode()) {
            case INVOKESPECIAL -> directCall(invocation);
            case INVOKEVIRTUAL -> handleInvokeVirtual(generator, invocation, parameters);
            case INVOKESTATIC -> invocation.method().name().stringValue();
            default -> throw new IllegalArgumentException(STR."\{invocation.opcode()} invocation not yet supported");
        };
        String returnVar;
        if (exceptions.anyActive()) {
            var nextLabel = labelGenerator.nextLabel();
            returnVar = generator.invoke(returnType, functionName, parameters, nextLabel, exceptions.getActiveHandler());
            generator.label(nextLabel);
        } else {
            returnVar = generator.call(returnType, functionName, parameters);
        }

        if (returnVar != null) {
            types.put(returnVar, returnType);
            stack.push(returnVar);
        }
    }

    private LlvmType arrayNestedType(LlvmType actualType) {
        return switch (actualType) {
            case LlvmType.Array array -> array.type();
            case LlvmType.SizedArray array -> array.type();
            case LlvmType.Pointer(LlvmType.Array array) -> array.type();
            case LlvmType.Pointer(LlvmType.SizedArray array) -> array.type();
            default -> null;
        };
    }

    private static int prepareVarArgParameters(IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, int parameterCount) {
        var parameter = stack.pop();
        if (!(types.get(parameter) instanceof LlvmType.SizedArray array)) return parameterCount;

        parameterCount = parameterCount - 1 + array.length();
        for (int i = 0; i < array.length(); i++) {
            var pointer = generator.getElementPointer(array, LlvmType.Primitive.POINTER, parameter, List.of("0", "1"));
            var actualArray = generator.load(LlvmType.Primitive.POINTER, LlvmType.Primitive.POINTER, pointer);
            var varPointer = generator.getElementPointer(array, LlvmType.Primitive.POINTER, actualArray, String.valueOf(i));
            var varName = generator.load(array.type(), new LlvmType.Pointer(array.type()), varPointer);
            switch (array.type()) {
                case LlvmType.Primitive p when p == LlvmType.Primitive.FLOAT -> {
                    var extendedName = generator.floatingPointExtend(varName);
                    types.put(extendedName, LlvmType.Primitive.DOUBLE);
                    stack.push(extendedName);
                }
                case LlvmType.Primitive p when p == LlvmType.Primitive.BYTE || p == LlvmType.Primitive.SHORT -> {
                    var extendedName = generator.signedExtend(array.type(), varName, LlvmType.Primitive.INT);
                    types.put(extendedName, LlvmType.Primitive.INT);
                    stack.push(extendedName);
                }
                default -> {
                    types.put(varName, array.type());
                    stack.push(varName);
                }
            }
        }
        return parameterCount;
    }

    private static String directCall(InvokeInstruction invocation) {
        return Utils.methodName(invocation.method());
    }

    private String handleInvokeVirtual(
        IrMethodGenerator generator, InvokeInstruction invocation, List<Parameter> parameters
    ) {
        var ownerClass = invocation.method().owner().name().stringValue();
        var virtualInfo = functionRegistry.getVirtual(ownerClass, invocation.name().stringValue(), invocation.typeSymbol());
        if (virtualInfo.isEmpty()) {
            return directCall(invocation);
        }

        // Load vtable pointer
        var parentType = new LlvmType.Declared(parent);
        var vtablePointer = generator.getElementPointer(parentType, new LlvmType.Pointer(parentType), parameters.getFirst().name(), List.of("0", "0"));

        // Get data from vtable pointer
        var vtableType = new LlvmType.Declared(STR."\{parent}_vtable_type");
        var vtableTypePointer = new LlvmType.Pointer(vtableType);
        var vtableData = generator.load(vtableTypePointer, new LlvmType.Pointer(vtableTypePointer), vtablePointer);

        // Get vtable pointer to function
        var vtableInfo = virtualInfo.get();
        var methodPointer = generator.getElementPointer(vtableType, vtableTypePointer, vtableData, List.of("0", String.valueOf(vtableInfo.index())));

        var function = vtableInfo.signature();
        var functionPointer = new LlvmType.Pointer(function);

        // Load function
        var functionName = generator.load(functionPointer, new LlvmType.Pointer(functionPointer), methodPointer);

        var actualType = parameters.getFirst().type();
        var expectedType = function.parameters().getFirst();
        if (!actualType.equals(expectedType)) {
            var parameter = parameters.removeFirst();
            var newParameter = generator.bitcast(parameter.type(), parameter.name(), expectedType);
            parameters.addFirst(new Parameter(newParameter, expectedType));
        }

        return functionName;
    }

    private void loadValue(Deque<String> stack, Locals locals, LoadInstruction instruction) {
        var local = locals.get(instruction.slot());
        stack.push(local.varName());
    }

    private String handleLabel(
        IrMethodGenerator generator,
        LabelGenerator labelGenerator,
        ExceptionState exceptions,
        String currentLabel,
        Locals locals,
        Deque<String> stack,
        SwitchStates switchStates,
        Label label
    ) {
        var nextLabel = labelGenerator.getLabel(label);
        exceptions.enteredLabel(nextLabel);
        if (exceptions.shouldGenerate()) {
            if (generator.isNotDone()) generator.branchLabel(nextLabel);
            generateLandingPad(generator, labelGenerator, exceptions);
        }

        if (exceptions.isCatching(currentLabel)) {
            generator.call(LlvmType.Primitive.VOID, "__cxa_end_catch", List.of());
        }
        switchStates.changedLabel(currentLabel, stack);
        generator.label(nextLabel);
        locals.enteredLabel(nextLabel);
        var exceptionVariable = exceptions.getExceptionVariable();
        if (exceptions.isCatching(nextLabel)) {
            var loaded = generator.load(LlvmType.Primitive.POINTER, LlvmType.Primitive.POINTER, exceptionVariable);
            var instance = generator.call(LlvmType.Primitive.POINTER, "__cxa_begin_catch", List.of(new Parameter(loaded, LlvmType.Primitive.POINTER)));
            stack.push(instance);
        }
        currentLabel = nextLabel;
        return currentLabel;
    }

    private void handleReturn(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ReturnInstruction instruction
    ) {
        if (instruction.opcode() == Opcode.RETURN) {
            generator.returnVoid();
            return;
        }

        if (types.get(stack.peekFirst()) instanceof LlvmType.Pointer p) {
            var varName = generator.load(p.type(), p, stack.pop());
            if (p.type() instanceof LlvmType.Declared) {
                generator.store(p.type(), varName, p, "%0");
                generator.returnVoid();
                return;
            }
            types.put(varName, p.type());
            stack.push(varName);
        } else if (types.get(stack.peekFirst()) == LlvmType.Primitive.POINTER) {
            var varName = generator.load(IrTypeMapper.mapType(instruction.typeKind()), LlvmType.Primitive.POINTER, stack.pop());
            stack.push(varName);
        }

        var originalType = types.get(stack.peekFirst());
        var requiredType = IrTypeMapper.mapType(instruction.typeKind());
        castIfNeeded(generator, stack, originalType, requiredType);
        generator.returnValue(stack.pop());
    }

    private void castIfNeeded(IrMethodGenerator generator, Deque<String> stack, LlvmType originalType, LlvmType.Primitive requiredType) {
        if (originalType == null || originalType == requiredType) return;

        var value = stack.pop();
        switch (originalType) {
            case LlvmType.Primitive original when original.isFloatingPoint() && requiredType.isFloatingPoint() -> {
                if (original.compareTo(requiredType) > 0) {
                    stack.push(generator.floatingPointTruncate(original, value, requiredType));
                } else {
                    stack.push(generator.floatingPointExtend(value));
                }
            }
            case LlvmType.Primitive original when original.isFloatingPoint() ->
                stack.push(generator.floatingPointToSignedInteger(original, value, requiredType));
            case LlvmType.Primitive original when requiredType.isFloatingPoint() ->
                stack.push(generator.signedToFloatingPoint(original, value, requiredType));
            case LlvmType.Primitive original -> {
                if (original.compareTo(requiredType) > 0) {
                    stack.push(generator.signedTruncate(original, value, requiredType));
                } else {
                    stack.push(generator.signedExtend(original, value, requiredType));
                }
            }
            default -> throw new IllegalStateException(STR."Unexpected value: \{originalType}");
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
        IrMethodGenerator generator, Deque<String> stack, Locals locals, Map<String, LlvmType> types, StoreInstruction instruction
    ) {
        var reference = stack.pop();
        var index = instruction.slot();
        var local = locals.get(index);

        var instructionType = IrTypeMapper.mapType(instruction.typeKind());
        var sourceType = types.getOrDefault(reference, instructionType);
        if (sourceType instanceof LlvmType.Array || sourceType instanceof LlvmType.SizedArray) {
            sourceType = new LlvmType.Pointer(sourceType);
        }
        var targetType = local.type();
        if (targetType != LlvmType.Primitive.POINTER) {
            targetType = new LlvmType.Pointer(targetType);
        }
        if (locals.contains(reference) && sourceType instanceof LlvmType.Pointer) {
            reference = generator.load(sourceType, new LlvmType.Pointer(sourceType), reference);
        }
        generator.store(Objects.requireNonNullElse(sourceType, local.type()), reference, targetType, local.varName());
        if (targetType == LlvmType.Primitive.POINTER) {
            types.put(local.varName(), new LlvmType.Pointer(sourceType));
        }
    }

    private void handleSwitch(
        IrMethodGenerator generator, Deque<String> stack, LabelGenerator labelGenerator, SwitchStates switchStates, TableSwitchInstruction instruction
    ) {
        var switchVar = generator.alloca(LlvmType.Primitive.POINTER);
        var cases = instruction.cases()
            .stream()
            .map(c -> Map.entry(c.caseValue(), labelGenerator.getLabel(c.target())))
            .toList();
        var defaultCase = labelGenerator.getLabel(instruction.defaultTarget());
        generator.switchBranch(
            stack.pop(),
            defaultCase,
            cases
        );
        switchStates.add(switchVar, defaultCase, cases.stream().map(Map.Entry::getValue).toList());
    }

    private void handleThrowInstruction(
        IrMethodGenerator generator, LabelGenerator labelGenerator, HashMap<String, LlvmType> types, ExceptionState exceptions, Deque<String> stack
    ) {
        var exception = stack.pop();

        var exceptionType = types.get(exception);
        if (!(exceptionType instanceof LlvmType.Pointer(LlvmType.Declared(var typeName)))) {
            var loaded = generator.load(LlvmType.Primitive.POINTER, LlvmType.Primitive.POINTER, exception);
            generator.call(LlvmType.Primitive.VOID, "__cxa_throw", List.of(
                new Parameter(loaded, LlvmType.Primitive.POINTER),
                new Parameter("null", LlvmType.Primitive.POINTER),
                new Parameter("null", LlvmType.Primitive.POINTER)
            ));
            generator.unreachable();
            return;
        }
        var descriptorType = new LlvmType.Global(Utils.escape(STR."P\{typeName}_type_info"));

        var variable = generator.call(LlvmType.Primitive.POINTER, "__cxa_allocate_exception", List.of(new Parameter("8", LlvmType.Primitive.LONG)));
        generator.store(exceptionType, exception, LlvmType.Primitive.POINTER, variable);
        var throwParameters = List.of(
            new Parameter(variable, types.get(exception)),
            new Parameter(descriptorType.toString(), LlvmType.Primitive.POINTER),
            new Parameter("null", LlvmType.Primitive.POINTER)
        );
        if (exceptions.anyActive()) {
            var next = labelGenerator.nextLabel();
            generator.invoke(LlvmType.Primitive.VOID, "__cxa_throw", throwParameters, next, exceptions.getActiveHandler());
            generator.label(next);
            generator.unreachable();
        } else {
            generator.call(LlvmType.Primitive.VOID, "__cxa_throw", throwParameters);
            generator.unreachable();
        }
    }
}
