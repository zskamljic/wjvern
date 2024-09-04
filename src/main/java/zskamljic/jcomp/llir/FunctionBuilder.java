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
import java.lang.classfile.constantpool.StringEntry;
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
    private static final String LANDING_PAD_COMPOSITE = "{ ptr, i32 }";

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
        // TODO: use other system of flagging native methods, for example annotations
        if (!method.flags().has(AccessFlag.STATIC) || !method.flags().has(AccessFlag.NATIVE)) {
            name = Utils.methodName(parent, method);
        }

        var actualReturnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
        var returnType = actualReturnType;
        if (returnType.isReferenceType()) {
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

        if (actualReturnType.isReferenceType()) {
            codeGenerator.addReturnParameter(actualReturnType);
        }

        for (int i = 0; i < parameterCount; i++) {
            var parameter = parameterCandidates.get(i);
            var paramType = IrTypeMapper.mapType(parameter.typeSymbol());
            if (paramType.isReferenceType()) {
                paramType = new LlvmType.Pointer(paramType);
            }
            codeGenerator.addParameter("local." + i, paramType);
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
            if (debug && !(element instanceof Label)) {
                generator.comment(element.toString());
            }
            switch (element) {
                case ArrayStoreInstruction as -> handleArrayStore(generator, stack, types, as);
                case ArrayLoadInstruction al -> handleArrayLoad(generator, stack, types, al);
                case BranchInstruction b -> handleBranch(generator, stack, types, labelGenerator, switchStates, currentLabel, b);
                case ConstantInstruction c -> handleConstant(stack, c);
                case ConvertInstruction c -> handleConvertInstruction(generator, stack, types, c);
                case ExceptionCatch e -> handleExceptionCatch(generator, labelGenerator, exceptionState, e);
                case FieldInstruction f -> handleFieldInstruction(generator, stack, types, f);
                case IncrementInstruction i -> handleIncrement(generator, locals, types, i);
                case InvokeInstruction i -> {
                    handleInvoke(generator, stack, types, labelGenerator, exceptionState, i);
                    if (i.opcode() == Opcode.INVOKESPECIAL && method.methodName().equalsString("<init>")) {
                        addInitVtable(generator);
                    }
                }
                case Label label ->
                    currentLabel = handleLabel(generator, labelGenerator, exceptionState, currentLabel, locals, stack, switchStates, label);
                case LineNumber l -> generator.comment("Line " + l.line());
                case LoadInstruction l -> handleLoad(generator, stack, types, locals, l);
                case LocalVariable v -> locals.register(v);
                case NewObjectInstruction n -> handleCreateNewObject(generator, stack, types, n);
                case NewPrimitiveArrayInstruction a -> handleCreatePrimitiveArray(generator, stack, types, a);
                case NewReferenceArrayInstruction a -> handleCreateRefArray(generator, stack, types, a);
                case OperatorInstruction o -> handleOperatorInstruction(generator, stack, labelGenerator, types, o);
                case ReturnInstruction r -> handleReturn(generator, stack, types, r);
                case StackInstruction s -> handleStackInstruction(stack, types, s);
                case StoreInstruction s -> handleStoreInstruction(generator, stack, locals, types, s);
                case TableSwitchInstruction s -> handleSwitch(generator, stack, labelGenerator, switchStates, s);
                case ThrowInstruction _ -> handleThrowInstruction(generator, labelGenerator, types, exceptionState, stack);
                default -> System.out.println(method.methodName() + ": " + element + ": not handled");
            }
        }
        if (debug && !stack.isEmpty()) {
            System.out.println("Remaining on stack in function " + parent + "." + method.methodName() + method.methodTypeSymbol().descriptorString() + ": ");
            while (!stack.isEmpty()) {
                System.out.println(stack.pop());
            }
        }
    }

    private void generateLandingPad(IrMethodGenerator generator, LabelGenerator labelGenerator, ExceptionState exceptions) {
        var dispatcherLabel = labelGenerator.nextLabel();
        generator.label(dispatcherLabel);
        var landingPad = generator.landingPad(exceptions.getActiveTypes());
        var exceptionVar = generator.extractValue(LANDING_PAD_COMPOSITE, landingPad, 0);
        generator.store(LlvmType.Primitive.POINTER, exceptionVar, LlvmType.Primitive.POINTER, exceptions.getExceptionVariable());
        var typeVar = generator.extractValue(LANDING_PAD_COMPOSITE, landingPad, 1);
        var nullHandler = exceptions.getDefaultHandler();
        var defaultCatchLabel = nullHandler.map(ExceptionInfo::catchStart)
            .orElseGet(labelGenerator::nextLabel);
        exceptions.saveDispatcher(dispatcherLabel);

        for (int i = 0; i < exceptions.getActive().size(); i++) {
            var handler = exceptions.getActive().get(i);
            var typeId = generator.call(LlvmType.Primitive.INT, "llvm.eh.typeid.for",
                List.of(new Parameter(handler.typeInfo().toString(), LlvmType.Primitive.POINTER)));
            var result = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.INT, typeVar, typeId);
            generator.branchBool(result, handler.catchStart(), defaultCatchLabel);
            if (i != exceptions.getActive().size() - 1) {
                generator.label(labelGenerator.nextLabel());
            }
        }

        if (nullHandler.isEmpty()) {
            var defaultDispatcher = exceptions.getDefaultDispatcher(labelGenerator::nextLabel);
            generator.label(defaultDispatcher);
            var cleanupPad = generator.landingPad(null);
            var exception = generator.extractValue(LANDING_PAD_COMPOSITE, cleanupPad, 0);
            generator.store(LlvmType.Primitive.POINTER, exception, LlvmType.Primitive.POINTER, exceptions.getExceptionVariable());
            generator.label(defaultCatchLabel);
            generator.call(LlvmType.Primitive.VOID, "__cxa_throw", List.of(new Parameter(exceptions.getExceptionVariable(), LlvmType.Primitive.POINTER))); // TODO: parameters from throw
            generator.unreachable();
        }
    }

    private void addInitVtable(IrMethodGenerator generator) {
        var parentClass = new LlvmType.Declared(parent);
        var vtablePointer = generator.getElementPointer(parentClass, new LlvmType.Pointer(parentClass), "%local.0", List.of("0", "0"));
        var vtableType = new LlvmType.Pointer(new LlvmType.Declared(parent + "_vtable_type"));
        var vtableTypePointer = new LlvmType.Pointer(vtableType);
        generator.store(vtableType, "@" + Utils.escape(parent + "_vtable_data"), vtableTypePointer, vtablePointer);
    }

    private void handleArrayStore(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ArrayStoreInstruction instruction
    ) {
        var value = stack.pop();
        var index = stack.pop();
        var arrayReference = loadIfNeeded(generator, types, stack.pop());

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
                System.err.println("Unknown array type: " + arrayType);
                componentType = LlvmType.Primitive.POINTER;
            }
        }
        var pointer = generator.getElementPointer(arrayType, new LlvmType.Pointer(arrayType), arrayReference, List.of("0", "1"));
        var actualArray = generator.load(LlvmType.Primitive.POINTER, LlvmType.Primitive.POINTER, pointer);
        index = loadIfNeeded(generator, types, index);
        var varName = generator.getElementPointer(componentType, LlvmType.Primitive.POINTER, actualArray, index);

        if (!(types.get(value) instanceof LlvmType.Pointer(LlvmType.Declared _))) {
            value = loadIfNeeded(generator, types, value);
        }
        var type = types.getOrDefault(value, IrTypeMapper.mapType(instruction.typeKind()));
        generator.store(type, value, LlvmType.Primitive.POINTER, varName);
    }

    private void handleArrayLoad(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ArrayLoadInstruction instruction
    ) {
        var index = loadIfNeeded(generator, types, stack.pop());
        var reference = loadIfNeeded(generator, types, stack.pop());

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
                    throw new IllegalStateException("Invalid reference type " + reference + ": " + types.get(reference));
                }
                yield instructionType;
            }
        };

        var indexPointer = generator.getElementPointer(type, LlvmType.Primitive.POINTER, array, index);
        if (instruction.typeKind() == TypeKind.ReferenceType) {
            type = new LlvmType.Pointer(type);
        }
        var value = generator.load(type, LlvmType.Primitive.POINTER, indexPointer);
        types.put(value, type);
        stack.push(value);
    }

    private void handleBranch(
        IrMethodGenerator generator,
        Deque<String> stack,
        Map<String, LlvmType> types,
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
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ACMPNE -> {
                var b = stack.pop();
                var a = stack.pop();

                var varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.POINTER, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPEQ -> {
                var b = loadIfNeeded(generator, types, stack.pop());
                b = castIfNeeded(generator, types.get(b), LlvmType.Primitive.INT, b);
                var a = loadIfNeeded(generator, types, stack.pop());
                a = castIfNeeded(generator, types.get(a), LlvmType.Primitive.INT, a);

                var varName = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPNE -> {
                var b = loadIfNeeded(generator, types, stack.pop());
                b = castIfNeeded(generator, types.get(b), LlvmType.Primitive.INT, b);
                var a = loadIfNeeded(generator, types, stack.pop());
                a = castIfNeeded(generator, types.get(a), LlvmType.Primitive.INT, a);

                var varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPLE -> {
                var b = loadIfNeeded(generator, types, stack.pop());
                b = castIfNeeded(generator, types.get(b), LlvmType.Primitive.INT, b);
                var a = loadIfNeeded(generator, types, stack.pop());
                a = castIfNeeded(generator, types.get(a), LlvmType.Primitive.INT, a);

                var varName = generator.compare(IrMethodGenerator.Condition.LESS_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPLT -> {
                var b = loadIfNeeded(generator, types, stack.pop());
                b = castIfNeeded(generator, types.get(b), LlvmType.Primitive.INT, b);
                var a = loadIfNeeded(generator, types, stack.pop());
                a = castIfNeeded(generator, types.get(a), LlvmType.Primitive.INT, a);

                var varName = generator.compare(IrMethodGenerator.Condition.LESS, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPGE -> {
                var b = loadIfNeeded(generator, types, stack.pop());
                b = castIfNeeded(generator, types.get(b), LlvmType.Primitive.INT, b);
                var a = loadIfNeeded(generator, types, stack.pop());
                a = castIfNeeded(generator, types.get(a), LlvmType.Primitive.INT, a);

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER_EQUAL, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IF_ICMPGT -> {
                var b = loadIfNeeded(generator, types, stack.pop());
                b = castIfNeeded(generator, types.get(b), LlvmType.Primitive.INT, b);
                var a = loadIfNeeded(generator, types, stack.pop());
                a = castIfNeeded(generator, types.get(a), LlvmType.Primitive.INT, a);

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER, LlvmType.Primitive.INT, a, b);
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFLE -> {
                var value = stack.pop();
                value = loadIfNeeded(generator, types, value);
                value = castIfNeeded(generator, types.get(value), LlvmType.Primitive.INT, value);

                var varName = generator.compare(IrMethodGenerator.Condition.LESS_EQUAL, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFLT -> {
                var value = stack.pop();
                value = loadIfNeeded(generator, types, value);
                value = castIfNeeded(generator, types.get(value), LlvmType.Primitive.INT, value);

                var varName = generator.compare(IrMethodGenerator.Condition.LESS, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFGE -> {
                var value = stack.pop();
                value = loadIfNeeded(generator, types, value);
                value = castIfNeeded(generator, types.get(value), LlvmType.Primitive.INT, value);

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER_EQUAL, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFGT -> {
                var value = stack.pop();
                value = loadIfNeeded(generator, types, value);
                value = castIfNeeded(generator, types.get(value), LlvmType.Primitive.INT, value);

                var varName = generator.compare(IrMethodGenerator.Condition.GREATER, LlvmType.Primitive.INT, value, "0");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFEQ -> {
                var value = loadIfNeeded(generator, types, stack.pop());
                value = castIfNeeded(generator, types.get(value), LlvmType.Primitive.INT, value);

                String varName;
                if (types.get(value) != LlvmType.Primitive.BOOLEAN) {
                    varName = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.INT, value, "0");
                } else {
                    varName = value;
                }
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFNE -> {
                var value = loadIfNeeded(generator, types, stack.pop());
                value = castIfNeeded(generator, types.get(value), LlvmType.Primitive.INT, value);

                String varName;
                if (types.get(value) != LlvmType.Primitive.BOOLEAN) {
                    varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.INT, value, "0");
                } else {
                    varName = value;
                }
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFNONNULL -> {
                var value = loadIfNeeded(generator, types, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.NOT_EQUAL, LlvmType.Primitive.POINTER, value, "null");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            case IFNULL -> {
                var value = loadIfNeeded(generator, types, stack.pop());

                var varName = generator.compare(IrMethodGenerator.Condition.EQUAL, LlvmType.Primitive.POINTER, value, "null");
                var ifTrue = labelGenerator.getLabel(instruction.target());
                var ifFalse = labelGenerator.nextLabel();
                generator.branchBool(varName, ifTrue, ifFalse);
                generator.label(ifFalse);
            }
            default -> throw new IllegalArgumentException(instruction.opcode() + " jump not supported yet");
        }
    }

    private String loadIfNeeded(IrMethodGenerator generator, Map<String, LlvmType> types, String value) {
        var type = types.get(value);
        if (type instanceof LlvmType.Pointer p && isLoadableType(p.type())) {
            var name = generator.load(p.type(), p, value);
            types.put(name, p.type());
            return name;
        }
        return value;
    }

    private boolean isLoadableType(LlvmType type) {
        return type instanceof LlvmType.Primitive || type instanceof LlvmType.Pointer;
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
        var sizeVariable = stack.peekFirst();
        var content = handleCreateArray(generator, stack, types, type);

        String arrayLength;
        var size = switch (type) {
            case BYTE -> 1;
            case LONG -> 8;
            default -> 4; // TODO: determine size based on type
        };
        if (sizeVariable != null && sizeVariable.matches("\\d+")) {
            arrayLength = String.valueOf(Integer.parseInt(sizeVariable) * size);
        } else {
            var arraySize = loadIfNeeded(generator, types, sizeVariable);
            if (size != 1) {
                arrayLength = generator.binaryOperator(IrMethodGenerator.Operator.MUL, LlvmType.Primitive.INT, arraySize, String.valueOf(size));
            } else {
                arrayLength = arraySize;
            }
        }

        if (type.isFloatingPoint()) {
            if (type == LlvmType.Primitive.FLOAT) {
                type = LlvmType.Primitive.INT;
            } else {
                type = LlvmType.Primitive.LONG;
            }
        }

        arrayLength = castIfNeeded(generator, types.get(arrayLength), LlvmType.Primitive.LONG, arrayLength);
        generator.call(LlvmType.Primitive.VOID, "llvm.memset.p0." + type, List.of(
            new Parameter(content, LlvmType.Primitive.POINTER),
            new Parameter("0", LlvmType.Primitive.BYTE),
            new Parameter(arrayLength, LlvmType.Primitive.LONG),
            new Parameter("false", LlvmType.Primitive.BOOLEAN)
        ));
    }

    private void handleCreateRefArray(
        IrMethodGenerator generator, ArrayDeque<String> stack, HashMap<String, LlvmType> types, NewReferenceArrayInstruction instruction
    ) {
        var type = IrTypeMapper.mapType(instruction.componentType().asSymbol());
        handleCreateArray(generator, stack, types, type);
    }

    private String handleCreateArray(IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, LlvmType type) {
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
        var content = generator.alloca(type, loadIfNeeded(generator, types, size));
        var contentPointer = generator.getElementPointer(arrayType, arrayPointer, varName, List.of("0", "1"));
        generator.store(LlvmType.Primitive.POINTER, content, LlvmType.Primitive.POINTER, contentPointer);
        stack.push(varName);
        types.put(varName, arrayPointer);

        return content;
    }

    private void handleOperatorInstruction(
        IrMethodGenerator generator, Deque<String> stack, LabelGenerator labelGenerator, Map<String, LlvmType> types, OperatorInstruction instruction
    ) {
        var operand = loadIfNeeded(generator, types, stack.pop());

        var type = IrTypeMapper.mapType(instruction.opcode().primaryTypeKind());
        var resultVar = switch (instruction.opcode()) {
            case ARRAYLENGTH -> {
                if (types.get(operand) instanceof LlvmType.Pointer) {
                    var pointer = generator.getElementPointer(ARRAY_TYPE, ARRAY_POINTER_TYPE, operand, List.of("0", "0"));
                    yield generator.load(LlvmType.Primitive.INT, LlvmType.Primitive.POINTER, pointer);
                } else {
                    yield generator.extractValue(ARRAY_TYPE.toString(), operand, 0);
                }
            }
            case DADD, FADD, IADD, LADD -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.ADD);
            case DDIV, FDIV, IDIV, LDIV -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.DIV);
            case DMUL, FMUL, IMUL, LMUL -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.MUL);
            case DSUB, FSUB, ISUB, LSUB -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.SUB);
            case IAND -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.AND);
            case INEG -> generator.binaryOperator(IrMethodGenerator.Operator.SUB, type, "0", operand);
            case IOR, LOR -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.OR);
            case ISHL, LSHL -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.SHL);
            case ISHR -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.ASHR);
            case IXOR -> handleBinaryOperator(generator, stack, types, type, operand, IrMethodGenerator.Operator.XOR);
            case LCMP -> signCompare(generator, labelGenerator, types, loadIfNeeded(generator, types, stack.pop()), operand);
            default -> throw new IllegalArgumentException(instruction.opcode() + " is not supported yet");
        };

        if (!types.containsKey(resultVar)) {
            types.put(resultVar, IrTypeMapper.mapType(instruction.typeKind()));
        }
        stack.push(resultVar);
    }

    private String handleBinaryOperator(
        IrMethodGenerator generator,
        Deque<String> stack,
        Map<String, LlvmType> types,
        LlvmType.Primitive type,
        String operand,
        IrMethodGenerator.Operator operator
    ) {
        var firstOperand = loadIfNeeded(generator, types, stack.pop());
        firstOperand = castIfNeeded(generator, types.get(firstOperand), type, firstOperand);
        var secondOperand = castIfNeeded(generator, types.get(operand), type, operand);

        return generator.binaryOperator(operator, type, firstOperand, secondOperand);
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
            case LDC, LDC_W, LDC2_W -> {
                var constant = ((ConstantInstruction.LoadConstantInstruction) instruction).constantEntry();
                if (constant instanceof StringEntry stringEntry) {
                    stack.push("@string." + stringEntry.index());
                } else {
                    stack.push(constant.constantValue().toString());
                }
            }
            default -> throw new IllegalArgumentException(instruction.opcode() + " constant is not supported yet");
        }
    }

    private void handleConvertInstruction(IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, ConvertInstruction c) {
        var source = loadIfNeeded(generator, types, stack.pop());

        var sourceType = (LlvmType.Primitive) types.getOrDefault(source, IrTypeMapper.mapType(c.fromType()));
        var targetType = IrTypeMapper.mapType(c.toType());

        var result = switch (c.opcode()) {
            case D2F -> generator.floatingPointTruncate(sourceType, source, targetType);
            case D2I, D2L, F2I, F2L -> generator.floatingPointToSignedInteger(sourceType, source, targetType);
            case F2D -> generator.floatingPointExtend(source);
            case I2D, I2F, L2F, L2D -> generator.signedToFloatingPoint(sourceType, source, targetType);
            case I2B, I2C, I2S, L2I -> generator.signedTruncate(sourceType, source, targetType);
            case I2L -> generator.signedExtend(sourceType, source, targetType);
            default -> throw new UnsupportedOperationException("Conversion for " + c.opcode() + " is not yet supported");
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

    private void handleFieldInstruction(IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, FieldInstruction instruction) {
        switch (instruction.opcode()) {
            case GETFIELD -> getField(generator, types, stack, instruction.field());
            case PUTFIELD -> putField(generator, types, stack, instruction);
            case GETSTATIC -> getStatic(generator, types, stack, instruction.field());
            case PUTSTATIC -> putStatic(generator, types, stack, instruction.field());
            default -> throw new IllegalArgumentException(instruction.opcode() + " field instruction is not yet supported");
        }
    }

    private void getField(IrMethodGenerator generator, Map<String, LlvmType> types, Deque<String> stack, FieldRefEntry field) {
        var fieldType = IrTypeMapper.mapType(field.typeSymbol());
        if (fieldType.isReferenceType()) {
            fieldType = new LlvmType.Pointer(fieldType);
        }

        var source = loadIfNeeded(generator, types, stack.pop());
        var parentType = new LlvmType.Declared(field.owner().name().stringValue());
        var varName = generator.getElementPointer(
            parentType, new LlvmType.Pointer(parentType), source,
            List.of("0", String.valueOf(fieldDefinition.indexOf(field.name().stringValue()) + 1))
        );

        var valueVar = generator.load(fieldType, new LlvmType.Pointer(fieldType), varName);
        types.put(valueVar, fieldType);
        stack.push(valueVar);
    }

    private void putField(IrMethodGenerator generator, Map<String, LlvmType> types, Deque<String> stack, FieldInstruction instruction) {
        var value = loadIfNeeded(generator, types, stack.pop());
        var objectReference = stack.pop();

        var fieldType = IrTypeMapper.mapType(instruction.field().typeSymbol());
        if (fieldType.isReferenceType()) {
            fieldType = new LlvmType.Pointer(fieldType);
        }

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

    private void putStatic(IrMethodGenerator generator, Map<String, LlvmType> types, Deque<String> stack, FieldRefEntry field) {
        var value = loadIfNeeded(generator, types, stack.pop());

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

            var variable = loadIfNeeded(generator, types, stack.pop());
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
            var typeName = invocation.method().owner().name().stringValue();
            var thisParameter = loadIfNeeded(generator, types, stack.pop());
            parameters.addFirst(new Parameter(thisParameter, new LlvmType.Pointer(new LlvmType.Declared(typeName))));
        }

        var returnType = IrTypeMapper.mapType(invocation.typeSymbol().returnType());
        if (returnType.isReferenceType()) {
            var retValue = generator.alloca(returnType);
            types.put(retValue, new LlvmType.Pointer(returnType));
            parameters.addFirst(new Parameter(retValue, new LlvmType.Pointer(returnType), true));
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
            case INVOKESTATIC -> {
                if (functionRegistry.isNative(invocation.owner().name().stringValue(), invocation.method())) {
                    yield invocation.method().name().stringValue();
                } else {
                    yield directCall(invocation);
                }
            }
            default -> throw new IllegalArgumentException(invocation.opcode() + " invocation not yet supported");
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
        if (!(types.get(parameter) instanceof LlvmType.Pointer(LlvmType.SizedArray array))) return parameterCount;

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
        var vtableType = new LlvmType.Declared(Utils.escape(ownerClass + "_vtable_type"));
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

    private void handleLoad(
        IrMethodGenerator generator, Deque<String> stack, Map<String, LlvmType> types, Locals locals, LoadInstruction instruction
    ) {
        var local = locals.get(instruction.slot());
        String varName;
        if (local.type() instanceof LlvmType.Pointer(LlvmType.Pointer p)) {
            varName = generator.load(p, local.type(), local.varName());
            types.put(varName, p);
        } else {
            varName = local.varName();
        }
        stack.push(varName);
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

        String returnVar;
        switch (types.getOrDefault(stack.peekFirst(), IrTypeMapper.mapType(instruction.typeKind()))) {
            case LlvmType.Pointer p -> {
                var varName = generator.load(p.type(), p, stack.pop());
                if (p.type().isReferenceType()) {
                    generator.store(p.type(), varName, p, "%0");
                    generator.returnVoid();
                    return;
                }
                types.put(varName, p.type());
                returnVar = varName;
            }
            case LlvmType.Primitive.POINTER ->
                returnVar = generator.load(IrTypeMapper.mapType(instruction.typeKind()), LlvmType.Primitive.POINTER, stack.pop());
            default -> returnVar = stack.pop();
        }

        var originalType = types.get(returnVar);
        var requiredType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
        if (requiredType instanceof LlvmType.Primitive primitiveReturn) {
            returnVar = castIfNeeded(generator, originalType, primitiveReturn, returnVar);
        }
        generator.returnValue(returnVar);
    }

    private String castIfNeeded(IrMethodGenerator generator, LlvmType originalType, LlvmType.Primitive requiredType, String value) {
        if (originalType == null || originalType == requiredType) return value;

        return switch (originalType) {
            case LlvmType.Primitive original when original.isFloatingPoint() && requiredType.isFloatingPoint() -> {
                if (original.compareTo(requiredType) > 0) {
                    yield generator.floatingPointTruncate(original, value, requiredType);
                } else {
                    yield generator.floatingPointExtend(value);
                }
            }
            case LlvmType.Primitive original when original.isFloatingPoint() -> generator.floatingPointToSignedInteger(original, value, requiredType);
            case LlvmType.Primitive original when requiredType.isFloatingPoint() -> generator.signedToFloatingPoint(original, value, requiredType);
            case LlvmType.Primitive original -> {
                if (original.compareTo(requiredType) > 0) {
                    yield generator.signedTruncate(original, value, requiredType);
                } else {
                    yield generator.signedExtend(original, value, requiredType);
                }
            }
            default -> throw new IllegalStateException("Unexpected value: " + originalType);
        };
    }

    private void handleStackInstruction(Deque<String> stack, Map<String, LlvmType> types, StackInstruction instruction) {
        switch (instruction.opcode()) {
            case POP -> stack.pop();
            case DUP -> stack.push(stack.peekFirst());
            case DUP2 -> {
                var first = stack.pop();
                if (types.get(first) != LlvmType.Primitive.LONG && types.get(first) != LlvmType.Primitive.DOUBLE) {
                    var second = stack.pop();
                    stack.push(second);
                    stack.push(first);
                    stack.push(second);
                }
                stack.push(first);
            }
            default -> throw new IllegalArgumentException(instruction.opcode() + " stack instruction not supported yet");
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
        var targetType = local.type();

        generator.store(Objects.requireNonNullElse(sourceType, local.type()), reference, targetType, local.varName());
        if (!types.containsKey(local.varName()) || types.get(local.varName()) == LlvmType.Primitive.POINTER) {
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
        var descriptorType = new LlvmType.Global(Utils.escape("P" + typeName + "_type_info"));

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
