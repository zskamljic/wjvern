package zskamljic.jcomp.llir.models;

import java.lang.constant.MethodTypeDesc;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

public class Vtable {
    private final List<VtableInfo> infoList = new ArrayList<>();
    private final Map<String, VtableInfo> vtableEntries = new HashMap<>();

    public void addAll(Vtable vtable) {
        infoList.addAll(vtable.infoList);
        vtableEntries.putAll(vtable.vtableEntries);
    }

    public void put(String name, MethodTypeDesc methodTypeDesc, VtableInfo vtableInfo) {
        vtableEntries.put(name + methodTypeDesc.descriptorString(), vtableInfo);
        infoList.add(vtableInfo);
    }

    public boolean isEmpty() {
        return infoList.isEmpty();
    }

    public boolean containsKey(String name, MethodTypeDesc methodTypeDesc) {
        return vtableEntries.containsKey(name + methodTypeDesc.descriptorString());
    }

    public VtableInfo get(String name, MethodTypeDesc methodTypeDesc) {
        return vtableEntries.get(name + methodTypeDesc.descriptorString());
    }

    public int index(VtableInfo vtableInfo) {
        return infoList.indexOf(vtableInfo);
    }

    public Stream<VtableInfo> stream() {
        return infoList.stream();
    }
}
