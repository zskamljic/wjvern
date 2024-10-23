package zskamljic.wjvern.llir.models;

import zskamljic.wjvern.llir.Utils;

public record ExceptionInfo(
    String tryStart,
    String tryEnd,
    String catchStart,
    LlvmType type,
    LlvmType.Global typeInfo
) {
    public static ExceptionInfo create(String tryStart, String tryEnd, String catchStart, LlvmType type) {
        LlvmType.Global typeInfo;
        if (type instanceof LlvmType.Declared(var name)) {
            typeInfo = new LlvmType.Global(Utils.escape("P" + name + "_type_info"));
        } else {
            typeInfo = null;
        }
        return new ExceptionInfo(tryStart, tryEnd, catchStart, type, typeInfo);
    }
}
