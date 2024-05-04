package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.CodeEntry;
import zskamljic.jcomp.llir.models.LlvmType;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class IrMethodGenerator {
    private final LlvmType returnType;
    private final String methodName;
    private final List<Map.Entry<String, LlvmType>> parameters;
    private final List<CodeEntry> codeEntries = new ArrayList<>();
    private final UnnamedGenerator unnamedGenerator = new UnnamedGenerator();

    public IrMethodGenerator(LlvmType returnType, String methodName) {
        this.returnType = returnType;
        this.methodName = methodName;
        parameters = new ArrayList<>();
    }

    void addParameter(String name, LlvmType type) {
        parameters.add(Map.entry(name, type));
    }

    boolean hasParameter(String name) {
        return parameters.stream().anyMatch(e -> e.getKey().equals(name));
    }

    public String alloca(LlvmType type) {
        var varName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Alloca(varName, type));
        return varName;
    }

    public void alloca(String varName, LlvmType type) {
        codeEntries.add(new CodeEntry.Alloca(varName, type));
    }

    public void bitcast(String newVar, LlvmType oldType, String source, LlvmType newType) {
        codeEntries.add(new CodeEntry.Bitcast(newVar, oldType, source, newType));
    }

    public String bitcast(LlvmType oldType, String source, LlvmType newType) {
        var newVar = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Bitcast(newVar, oldType, source, newType));
        return newVar;
    }

    public String binaryOperator(Operator operator, LlvmType.Primitive type, String operand1, String operand2) {
        var newVar = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.BinaryOperation(newVar, operator, type, operand1, operand2));
        return newVar;
    }

    public void branchBool(String value, String ifTrue, String ifFalse) {
        codeEntries.add(new CodeEntry.Branch.Bool(value, ifTrue, ifFalse));
    }

    public void branchLabel(String label) {
        codeEntries.add(new CodeEntry.Branch.Label(label));
    }

    public void comment(String comment) {
        codeEntries.add(new CodeEntry.Comment(comment));
    }

    public String compare(Condition condition, LlvmType type, String a, String b) {
        var varName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Compare(varName, condition, type, a, b));
        return varName;
    }

    public String floatingPointExtend(String varName) {
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.FloatingPointExtend(newName, varName));
        return newName;
    }

    public String floatingPointToSignedInteger(LlvmType.Primitive source, String value, LlvmType.Primitive target) {
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.FloatingPointToSignedInt(newName, source, value, target));
        return newName;
    }

    public String floatingPointTruncate(LlvmType.Primitive original, String value, LlvmType.Primitive target) {
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.FloatingPointTruncate(newName, original, value, target));
        return newName;
    }

    public String getElementPointer(LlvmType targetType, LlvmType sourceType, String source, String index) {
        var variableName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.GetElementByPointer(variableName, targetType, sourceType, source, index));
        return variableName;
    }

    public String call(LlvmType returnType, String functionName, List<Map.Entry<String, LlvmType>> parameters) {
        String returnVar = null;
        if (returnType != LlvmType.Primitive.VOID) {
            returnVar = unnamedGenerator.generateNext();
        }

        codeEntries.add(new CodeEntry.Call(returnVar, returnType, functionName, parameters));
        return returnVar;
    }

    public String extractValue(String landingPad, int index) {
        var returnVar = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.ExtractValue(returnVar, landingPad, index));
        return returnVar;
    }

    public String invoke(LlvmType returnType, String name, List<Map.Entry<String, LlvmType>> parameters, String next, String unwind) {
        String returnVar = null;
        if (returnType != LlvmType.Primitive.VOID) {
            returnVar = unnamedGenerator.generateNext();
        }

        codeEntries.add(new CodeEntry.Invoke(returnVar, returnType, name, parameters, next, unwind));
        return returnVar;
    }

    public void label(String label) {
        if (codeEntries.isEmpty()) {
            unnamedGenerator.skipAnonymousBlock();
        }
        if (isNotDone()) {
            branchLabel(label);
        }
        codeEntries.add(new CodeEntry.Label(label));
    }

    public String landingPad(List<LlvmType.Global> type) {
        var returnVar = unnamedGenerator.generateNext();

        codeEntries.add(new CodeEntry.LandingPad(returnVar, type));

        return returnVar;
    }

    public String load(LlvmType targetType, LlvmType sourceType, String variable) {
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.Load(newName, targetType, sourceType, variable));
        return newName;
    }

    public void returnValue(String variable) {
        codeEntries.add(new CodeEntry.Return(returnType, variable));
    }

    public void returnVoid() {
        codeEntries.add(new CodeEntry.Return(returnType, null));
    }

    public String signedExtend(LlvmType originalType, String source, LlvmType targetType) {
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.SignedExtend(newName, originalType, source, targetType));
        return newName;
    }

    public String signedToFloatingPoint(LlvmType.Primitive source, String value, LlvmType.Primitive target) {
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.SignedToFloatingPoint(newName, source, value, target));
        return newName;
    }

    public String signedTruncate(LlvmType.Primitive original, String value, LlvmType.Primitive target) {
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.SignedTruncate(newName, original, value, target));
        return newName;
    }

    public void store(LlvmType type, String value, LlvmType targetType, String varName) {
        codeEntries.add(new CodeEntry.Store(type, value, targetType, varName));
    }

    public void switchBranch(String variable, String defaultCase, List<Map.Entry<Integer, String>> cases) {
        codeEntries.add(new CodeEntry.Switch(variable, defaultCase, cases));
    }

    public void unreachable() {
        codeEntries.add(new CodeEntry.Unreachable());
    }

    public String generate() {
        var builder = new StringBuilder();

        writeMethodDefinition(builder);

        // Java sometimes has labels at the end, without instructions following. That's invalid in LLVM IR
        if (codeEntries.getLast() instanceof CodeEntry.Label) {
            codeEntries.removeLast();
            // Automatically added if there is a label inserted
            if (codeEntries.getLast() instanceof CodeEntry.Branch.Label) {
                codeEntries.removeLast();
            }
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

    private void writeMethodDefinition(StringBuilder builder) {
        builder.append("define ").append(returnType)
            .append(" @").append(Utils.escape(methodName))
            .append("(");

        var paramString = parameters.stream()
            .map(p -> {
                var name = p.getKey();
                var type = p.getValue();
                if (type instanceof LlvmType.Array(var length, var typeName)) {
                    return STR."[\{typeName} x \{length}] %\{name}";
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
        SUB
    }
}
