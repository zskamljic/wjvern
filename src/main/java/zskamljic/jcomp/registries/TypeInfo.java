package zskamljic.jcomp.registries;

import java.util.ArrayList;
import java.util.List;

public record TypeInfo(
    List<Integer> types,
    List<Integer> interfaces
) {
    public void consolidateTypes() {
        var interfaceOnlyTypes = new ArrayList<>(interfaces);
        interfaceOnlyTypes.removeAll(types);
        types.addAll(interfaceOnlyTypes);
    }
}
