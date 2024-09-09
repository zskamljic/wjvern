package zskamljic.jcomp.llir.models;

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
