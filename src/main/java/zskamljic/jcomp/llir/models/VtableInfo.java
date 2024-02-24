package zskamljic.jcomp.llir.models;

public record VtableInfo(LlvmType.Pointer signature, int index, String functionName) {
}
