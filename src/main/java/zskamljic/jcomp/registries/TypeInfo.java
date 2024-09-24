package zskamljic.jcomp.registries;

import java.util.List;

public record TypeInfo(
    List<Integer> types,
    List<Integer> interfaces
) {
    public TypeInfo copyOf() {
        return new TypeInfo(types, interfaces);
    }
}
