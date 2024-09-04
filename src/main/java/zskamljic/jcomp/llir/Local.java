package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;

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
