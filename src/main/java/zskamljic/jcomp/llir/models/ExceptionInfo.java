package zskamljic.jcomp.llir.models;

import zskamljic.jcomp.llir.Utils;

public class ExceptionInfo {
    private final String tryStart;
    private final String tryEnd;
    private final String catchStart;
    private final LlvmType type;
    private final LlvmType.Global typeInfo;
    private String variable;

    public ExceptionInfo(String tryStart, String tryEnd, String catchStart, LlvmType type) {
        this.tryStart = tryStart;
        this.tryEnd = tryEnd;
        this.catchStart = catchStart;
        this.type = type;
        if (type instanceof LlvmType.Declared(var name)) {
            this.typeInfo = new LlvmType.Global(Utils.escape(STR."P\{name}_type_info"));
        } else {
            this.typeInfo = null;
        }
    }

    public String getTryStart() {
        return tryStart;
    }

    public String getTryEnd() {
        return tryEnd;
    }

    public String getCatchStart() {
        return catchStart;
    }

    public LlvmType getType() {
        return type;
    }

    public LlvmType.Global getExceptionTypeInfo() {
        return typeInfo;
    }

    public void setVariable(String variable) {
        this.variable = variable;
    }

    public String getVariable() {
        return variable;
    }
}
