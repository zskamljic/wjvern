package zskamljic.jcomp.llir.models;

import java.util.stream.Collectors;

public record VtableInfo(LlvmType.Function signature, String functionName, String simpleName, int index) {
    public String toDeclarationString() {
        var signature = "declare " +
            signature().returnType() + " " + functionName() + "(" +
            signature().parameters().stream()
                .map(String::valueOf)
                .collect(Collectors.joining(", ")) + ")";

        if (signature().isNative()) {
            signature += " nounwind";
        }

        return signature;
    }
}
