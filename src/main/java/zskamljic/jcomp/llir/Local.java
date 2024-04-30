package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;

public record Local(String varName, LlvmType type, int slot, String start, String end) {
}
