package zskamljic.wjvern.llir.models;

public record Parameter(String name, LlvmType type, boolean isReturn) {
    public Parameter(String name, LlvmType type) {
        this(name, type, false);
    }
}
