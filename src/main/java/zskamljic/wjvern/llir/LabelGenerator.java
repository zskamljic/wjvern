package zskamljic.wjvern.llir;

import java.lang.classfile.Label;
import java.util.HashMap;
import java.util.Map;

public class LabelGenerator {
    private int index;

    private final Map<Label, String> labels = new HashMap<>();

    public String getLabel(Label label) {
        return labels.computeIfAbsent(label, ignored -> nextLabel());
    }

    public String nextLabel() {
        return "label" + index++;
    }
}
