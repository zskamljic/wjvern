package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.CodeEntry;
import zskamljic.jcomp.llir.models.LlvmType;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class IrCodeGenerator {
    private final LlvmType returnType;
    private final String methodName;
    private final List<Map.Entry<String, LlvmType>> parameters;
    private final List<CodeEntry> codeEntries = new ArrayList<>();

    public IrCodeGenerator(LlvmType returnType, String methodName) {
        this.returnType = returnType;
        if (methodName.contains("<")) {
            methodName = STR."\"\{methodName}\"";
        }
        this.methodName = methodName;
        parameters = new ArrayList<>();
    }

    void addParameter(String name, LlvmType type) {
        parameters.add(Map.entry(name, type));
    }

    public void alloca(String varName, LlvmType type) {
        codeEntries.add(new CodeEntry.Alloca(varName, type));
    }

    public void bitcast(String newVar, LlvmType oldType, String source, LlvmType newType) {
        codeEntries.add(new CodeEntry.Bitcast(newVar, oldType, source, newType));
    }

    public void binaryOperator(String newVar, Operator operator, LlvmType.Primitive type, String operand1, String operand2) {
        codeEntries.add(new CodeEntry.BinaryOperation(newVar, operator, type, operand1, operand2));
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

    public void compare(String varName, Condition condition, LlvmType type, String a, String b) {
        codeEntries.add(new CodeEntry.Compare(varName, condition, type, a, b));
    }
    public void floatingPointExtend(String newName, String varName) {
        codeEntries.add(new CodeEntry.FloatingPointExtend(newName, varName));
    }

    public void getElementPointer(String variableName, LlvmType targetType, LlvmType sourceType, String source, String index) {
        codeEntries.add(new CodeEntry.GetElementByPointer(variableName, targetType, sourceType, source, index));
    }

    public void invoke(String returnVar, LlvmType returnType, String functionName, List<Map.Entry<String, LlvmType>> parameters) {
        codeEntries.add(new CodeEntry.Invoke(returnVar, returnType, functionName, parameters));
    }

    public void label(String label) {
        if (!codeEntries.isEmpty() && !(codeEntries.getLast() instanceof CodeEntry.Branch)) {
            branchLabel(label);
        }
        codeEntries.add(new CodeEntry.Label(label));
    }

    public void load(String newName, LlvmType targetType, LlvmType sourceType, String variable) {
        codeEntries.add(new CodeEntry.Load(newName, targetType, sourceType, variable));
    }

    public void returnValue(String variable) {
        codeEntries.add(new CodeEntry.Return(returnType, variable));
    }

    public void returnVoid() {
        codeEntries.add(new CodeEntry.Return(returnType, null));
    }

    public void signedExtend(String newName, LlvmType originalType, String targetType, String source) {
        codeEntries.add(new CodeEntry.SignedExtend(newName, originalType, targetType, source));
    }

    public void store(LlvmType type, String value, LlvmType targetType, String varName) {
        codeEntries.add(new CodeEntry.Store(type, value, targetType, varName));
    }

    public String generate() {
        var builder = new StringBuilder();

        writeMethodDefinition(builder);

        codeEntries.forEach(e -> {
            if (!(e instanceof CodeEntry.Label)) {
                builder.append(" ".repeat(2));
            }
            builder.append(e).append("\n");
        });

        builder.append("}");

        return builder.toString();
    }

    private void writeMethodDefinition(StringBuilder builder) {
        builder.append("define ").append(returnType)
            .append(" @").append(methodName)
            .append("(");

        for (var parameter : parameters) {
            var name = parameter.getKey();
            var type = parameter.getValue();
            switch (type) {
                case LlvmType.Pointer(var typeName) -> builder.append(typeName).append("*");
                case LlvmType.Array(var length, var typeName) -> builder.append(STR."[\{typeName} x \{length}]");
                default -> builder.append(type);
            }
            builder.append(" %").append(name);
        }

        builder.append(") {\n");
    }

    public boolean isEmpty() {
        return codeEntries.isEmpty();
    }

    public enum Condition {
        GREATER_EQUAL,
        LESS_EQUAL
    }

    public enum Operator {
        ADD,
        DIV,
        MUL,
        SUB
    }
}
