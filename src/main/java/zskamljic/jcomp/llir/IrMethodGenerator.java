package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.CodeEntry;
import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.Parameter;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Predicate;
import java.util.stream.Collectors;

public class IrMethodGenerator {
    private final LlvmType returnType;
    private final String methodName;
    private final List<Parameter> parameters;
    private final List<CodeEntry> codeEntries = new ArrayList<>();
    private final UnnamedGenerator unnamedGenerator = new UnnamedGenerator();

    public IrMethodGenerator(LlvmType returnType, String methodName) {
        this.returnType = returnType;
        this.methodName = methodName;
        parameters = new ArrayList<>();
    }

    void addReturnParameter(LlvmType returnType) {
        parameters.add(new Parameter(unnamedGenerator.generateNext(), returnType, true));
    }

    void addParameter(String name, LlvmType type) {
        parameters.add(new Parameter(name, type));
    }

    boolean hasParameter(String name) {
        return parameters.stream().anyMatch(e -> e.name().equals(name));
    }

    public String alloca(LlvmType type) {
        incrementIfNeeded(null);
        var varName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Alloca(varName, type));
        return varName;
    }

    public String alloca(LlvmType type, String size) {
        incrementIfNeeded(null);
        var varName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Alloca(varName, type, size));
        return varName;
    }

    public void alloca(String varName, LlvmType type) {
        add(new CodeEntry.Alloca(varName, type));
    }

    public String bitcast(LlvmType oldType, String source, LlvmType newType) {
        incrementIfNeeded(null);
        var newVar = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Bitcast(newVar, oldType, source, newType));
        return newVar;
    }

    public String binaryOperator(Operator operator, LlvmType.Primitive type, String operand1, String operand2) {
        incrementIfNeeded(null);
        var newVar = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.BinaryOperation(newVar, operator, type, operand1, operand2));
        return newVar;
    }

    public void branchBool(String value, String ifTrue, String ifFalse) {
        add(new CodeEntry.Branch.Bool(value, ifTrue, ifFalse));
    }

    public void branchLabel(String label) {
        add(new CodeEntry.Branch.Label(label));
    }

    public void comment(String comment) {
        add(new CodeEntry.Comment(comment));
    }

    public String compare(Condition condition, LlvmType type, String a, String b) {
        incrementIfNeeded(null);
        var varName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Compare(varName, condition, type, a, b));
        return varName;
    }

    public String floatingPointExtend(String varName) {
        incrementIfNeeded(null);
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.FloatingPointExtend(newName, varName));
        return newName;
    }

    public String floatingPointToSignedInteger(LlvmType.Primitive source, String value, LlvmType.Primitive target) {
        incrementIfNeeded(null);
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.FloatingPointToSignedInt(newName, source, value, target));
        return newName;
    }

    public String floatingPointTruncate(LlvmType.Primitive original, String value, LlvmType.Primitive target) {
        incrementIfNeeded(null);
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.FloatingPointTruncate(newName, original, value, target));
        return newName;
    }

    public String getElementPointer(LlvmType targetType, LlvmType sourceType, String source, String index) {
        return getElementPointer(targetType, sourceType, source, List.of(index));
    }

    public String getElementPointer(LlvmType targetType, LlvmType sourceType, String source, List<String> indices) {
        incrementIfNeeded(null);
        var variableName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.GetElementByPointer(variableName, targetType, sourceType, source, indices));
        return variableName;
    }

    public String call(LlvmType returnType, String functionName, List<Parameter> parameters) {
        String returnVar = null;
        if (returnType != LlvmType.Primitive.VOID) {
            returnVar = unnamedGenerator.generateNext();
        }

        codeEntries.add(new CodeEntry.Call(returnVar, returnType, functionName, parameters));
        return returnVar;
    }

    public String extractValue(String landingPad, int index) {
        incrementIfNeeded(null);
        var returnVar = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.ExtractValue(returnVar, landingPad, index));
        return returnVar;
    }

    public String invoke(LlvmType returnType, String name, List<Parameter> parameters, String next, String unwind) {
        String returnVar = null;
        if (returnType != LlvmType.Primitive.VOID) {
            incrementIfNeeded(null);
            returnVar = unnamedGenerator.generateNext();
        }

        codeEntries.add(new CodeEntry.Invoke(returnVar, returnType, name, parameters, next, unwind));
        return returnVar;
    }

    public void label(String label) {
        if (isNotDone()) {
            branchLabel(label);
        }
        codeEntries.add(new CodeEntry.Label(label));
    }

    public String landingPad(List<LlvmType.Global> type) {
        incrementIfNeeded(null);
        var returnVar = unnamedGenerator.generateNext();

        codeEntries.add(new CodeEntry.LandingPad(returnVar, type));

        return returnVar;
    }

    public String load(LlvmType targetType, LlvmType sourceType, String variable) {
        incrementIfNeeded(null);
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Load(newName, targetType, sourceType, variable));
        return newName;
    }

    public void returnValue(String variable) {
        add(new CodeEntry.Return(returnType, variable));
    }

    public void returnVoid() {
        add(new CodeEntry.Return(returnType, null));
    }

    public String signedExtend(LlvmType originalType, String source, LlvmType targetType) {
        incrementIfNeeded(null);
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.SignedExtend(newName, originalType, source, targetType));
        return newName;
    }

    public String signedToFloatingPoint(LlvmType.Primitive source, String value, LlvmType.Primitive target) {
        incrementIfNeeded(null);
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.SignedToFloatingPoint(newName, source, value, target));
        return newName;
    }

    public String signedTruncate(LlvmType.Primitive original, String value, LlvmType.Primitive target) {
        incrementIfNeeded(null);
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.SignedTruncate(newName, original, value, target));
        return newName;
    }

    public void store(LlvmType type, String value, LlvmType targetType, String varName) {
        add(new CodeEntry.Store(type, value, targetType, varName));
    }

    public void switchBranch(String variable, String defaultCase, List<Map.Entry<Integer, String>> cases) {
        add(new CodeEntry.Switch(variable, defaultCase, cases));
    }

    public void unreachable() {
        add(new CodeEntry.Unreachable());
    }

    public String generate() {
        var builder = new StringBuilder();

        writeMethodDefinition(builder);

        // Java sometimes has labels at the end, without instructions following. That's invalid in LLVM IR
        var hasLastEmptyLabel = codeEntries.reversed()
            .stream()
            .filter(Predicate.not(CodeEntry.Comment.class::isInstance))
            .findFirst()
            .stream()
            .anyMatch(CodeEntry.Label.class::isInstance);
        if (hasLastEmptyLabel) {
            unreachable();
        }

        codeEntries.forEach(e -> {
            if (!(e instanceof CodeEntry.Label)) {
                builder.append(" ".repeat(2));
            }
            builder.append(e).append("\n");
        });

        builder.append("}");

        return builder.toString();
    }

    public boolean isNotDone() {
        return !codeEntries.isEmpty() &&
            !(codeEntries.getLast() instanceof CodeEntry.Branch) &&
            !(codeEntries.getLast() instanceof CodeEntry.Return) &&
            !(codeEntries.getLast() instanceof CodeEntry.Unreachable) &&
            !(codeEntries.getLast() instanceof CodeEntry.Invoke) &&
            !(codeEntries.getLast() instanceof CodeEntry.Switch);
    }

    void add(CodeEntry codeEntry) {
        incrementIfNeeded(codeEntry);
        codeEntries.add(codeEntry);
    }

    private void incrementIfNeeded(CodeEntry codeEntry) {
        if (codeEntries.isEmpty() && !(codeEntry instanceof CodeEntry.Label)) {
            unnamedGenerator.generateNext();
        }
    }

    private void writeMethodDefinition(StringBuilder builder) {
        builder.append("define ").append(returnType)
            .append(" @").append(Utils.escape(methodName))
            .append("(");

        var paramString = parameters.stream()
            .map(p -> {
                var name = p.name();
                var type = p.type();
                if (p.isReturn()) {
                    return STR."ptr sret(\{type}) \{name}";
                } else {
                    return STR."\{type} %\{name}";
                }
            })
            .map(Object::toString)
            .collect(Collectors.joining(", "));

        builder.append(paramString).append(") personality ptr @__gxx_personality_v0 {\n");
    }

    public enum Condition {
        EQUAL,
        GREATER,
        GREATER_EQUAL,
        LESS,
        LESS_EQUAL,
        NOT_EQUAL,
    }

    public enum Operator {
        ADD,
        DIV,
        MUL,
        SUB,
        ASHR,
        AND,
        OR
    }
}
