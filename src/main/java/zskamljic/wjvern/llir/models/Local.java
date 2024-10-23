package zskamljic.wjvern.llir.models;

public record Local(
    String codeName,
    LlvmType type,
    int slot,
    String start,
    String end
) {
    public String varName() {
        return "%local." + slot;
    }
}
