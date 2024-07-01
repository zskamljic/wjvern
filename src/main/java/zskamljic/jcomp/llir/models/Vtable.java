package zskamljic.jcomp.llir.models;

import java.lang.constant.MethodTypeDesc;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;

public class Vtable {
    private final Map<String, VtableInfo> vtableEntries = new HashMap<>();

    public void addAll(Vtable vtable) {
        vtableEntries.putAll(vtable.vtableEntries);
    }

    public void put(String name, MethodTypeDesc methodTypeDesc, LlvmType.Function functionSignature, String functionName) {
        var previous = vtableEntries.get(name + methodTypeDesc.descriptorString());
        if (previous != null) {
            var index = previous.index();
            vtableEntries.put(name + methodTypeDesc.descriptorString(), new VtableInfo(functionSignature, functionName, index));
        } else {
            vtableEntries.put(name + methodTypeDesc.descriptorString(), new VtableInfo(functionSignature, functionName, vtableEntries.size()));
        }
    }

    public boolean isEmpty() {
        return vtableEntries.isEmpty();
    }

    public Optional<VtableInfo> get(String name, MethodTypeDesc methodTypeDesc) {
        return Optional.ofNullable(vtableEntries.get(name + methodTypeDesc.descriptorString()));
    }

    public Stream<VtableInfo> stream() {
        return vtableEntries.values().stream().sorted(Comparator.comparing(VtableInfo::index));
    }

    public List<LlvmType.Declared> requiredTypes() {
        return vtableEntries.values()
            .stream()
            .map(VtableInfo::signature)
            .<LlvmType>mapMulti((vi, c) -> {
                c.accept(vi.returnType());
                vi.parameters().forEach(c);
            })
            .distinct()
            .filter(LlvmType.Declared.class::isInstance)
            .map(LlvmType.Declared.class::cast)
            .toList();
    }
}
