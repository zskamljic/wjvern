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
        if (methodName.contains("<")) {
            methodName = STR."\"\{methodName}\"";
        }
        this.methodName = methodName;
        parameters = new ArrayList<>();
    }

    void addParameter(String name, LlvmType type) {
        parameters.add(Map.entry(name, type));
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

    public String getElementPointer(LlvmType targetType, LlvmType sourceType, String source, String index) {
        var variableName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.GetElementByPointer(variableName, targetType, sourceType, source, index));
        return variableName;
    }

    public String invoke(LlvmType returnType, String functionName, List<Map.Entry<String, LlvmType>> parameters) {
        String returnVar = null;
        if (returnType != LlvmType.Primitive.VOID) {
            returnVar = unnamedGenerator.generateNext();
        }

        codeEntries.add(new CodeEntry.Invoke(returnVar, returnType, functionName, parameters));
        return returnVar;
    }

    public void label(String label) {
        if (codeEntries.isEmpty()) {
            unnamedGenerator.skipAnonymousBlock();
        }
        if (!codeEntries.isEmpty() && !(codeEntries.getLast() instanceof CodeEntry.Branch)) {
            branchLabel(label);
        }
        codeEntries.add(new CodeEntry.Label(label));
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

    public String signedExtend(LlvmType originalType, String targetType, String source) {
        var newName = unnamedGenerator.generateNext();
        codeEntries.add(new CodeEntry.SignedExtend(newName, originalType, targetType, source));
        return newName;
    }

    public void store(LlvmType type, String value, LlvmType targetType, String varName) {
        codeEntries.add(new CodeEntry.Store(type, value, targetType, varName));
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

        builder.append(paramString).append(") {\n");
    }

    public enum Condition {
        GREATER_EQUAL,
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
