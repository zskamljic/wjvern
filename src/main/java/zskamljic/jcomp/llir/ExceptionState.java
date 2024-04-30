package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.ExceptionInfo;
import zskamljic.jcomp.llir.models.LlvmType;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Supplier;

public class ExceptionState {
    private final List<ExceptionInfo> tryCatchBlocks = new ArrayList<>();
    private final List<ExceptionInfo> activeTryBlocks = new ArrayList<>();
    private final Map<List<ExceptionInfo>, String> dispatcherLabels = new HashMap<>();
    private String defaultDispatcher;
    private String exceptionVariable;

    public void add(ExceptionInfo exceptionInfo) {
        tryCatchBlocks.add(exceptionInfo);
    }

    public void enteredLabel(String currentLabel) {
        tryCatchBlocks.stream()
            .filter(e -> e.tryStart().equals(currentLabel))
            .forEach(activeTryBlocks::add);

        activeTryBlocks.removeIf(e -> e.tryEnd().equals(currentLabel));
    }

    public boolean anyActive() {
        return activeTryBlocks.stream()
            .anyMatch(e -> e.typeInfo() != null);
    }

    public List<LlvmType.Global> getActiveTypes() {
        return activeTryBlocks.stream()
            .map(ExceptionInfo::typeInfo)
            .filter(Objects::nonNull)
            .toList();
    }

    public Optional<ExceptionInfo> getDefaultHandler() {
        return activeTryBlocks.stream()
            .filter(a -> a.type() == null)
            .findFirst();
    }

    public List<ExceptionInfo> getActive() {
        return activeTryBlocks.stream()
            .filter(e -> e.typeInfo() != null)
            .toList();
    }

    public String getActiveHandler() {
        return dispatcherLabels.get(activeTryBlocks);
    }

    public boolean shouldGenerate() {
        return activeTryBlocks.stream().anyMatch(e -> e.typeInfo() != null) &&
            !dispatcherLabels.containsKey(activeTryBlocks);
    }

    public void saveDispatcher(String dispatcherLabel) {
        dispatcherLabels.put(new ArrayList<>(activeTryBlocks), dispatcherLabel);
    }

    public String getDefaultDispatcher(Supplier<String> generator) {
        if (defaultDispatcher == null) {
            defaultDispatcher = generator.get();
        }
        return defaultDispatcher;
    }

    public boolean shouldGenerateVariables() {
        return exceptionVariable == null;
    }

    public void setExceptionVariable(String exception) {
        exceptionVariable = exception;
    }

    public String getExceptionVariable() {
        return exceptionVariable;
    }

    public boolean isCatching(String label) {
        return tryCatchBlocks.stream()
            .anyMatch(b -> b.catchStart().equals(label));
    }
}
