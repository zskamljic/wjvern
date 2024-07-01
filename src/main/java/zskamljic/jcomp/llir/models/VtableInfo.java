package zskamljic.jcomp.llir.models;

public record VtableInfo(LlvmType.Function signature, String functionName, int index) {
}
