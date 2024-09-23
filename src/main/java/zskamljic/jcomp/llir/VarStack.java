package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.PhiEntry;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

public class VarStack {
    private final Deque<VarStack> parentStates = new ArrayDeque<>();
    private final IrMethodGenerator generator;
    private final Map<String, LlvmType> types;
    private Deque<StackEntry> currentStack;
    private Map<String, Deque<StackEntry>> parallelStacks;
    private Map<String, String> labelEnds;
    private String currentLabel;

    public VarStack(IrMethodGenerator generator, Map<String, LlvmType> types) {
        this.generator = generator;
        this.types = types;
        this.currentStack = new ArrayDeque<>();
        this.parallelStacks = new HashMap<>();
        this.labelEnds = new HashMap<>();
    }

    public VarStack(IrMethodGenerator generator, Map<String, LlvmType> types, VarStack other) {
        this.generator = generator;
        this.types = types;
        this.currentStack = new ArrayDeque<>(other.currentStack);
        this.parallelStacks = new HashMap<>(other.parallelStacks);
        this.labelEnds = new HashMap<>(other.labelEnds);
    }

    public void push(String value) {
        currentStack.push(new StackEntry(currentLabel, value));
    }

    public String pop() {
        return currentStack.pop().variable();
    }

    public String peekFirst() {
        return Optional.ofNullable(currentStack.peekFirst()).map(StackEntry::variable).orElse(null);
    }

    public boolean isEmpty() {
        return currentStack.isEmpty();
    }

    public void startBranch(String... labels) {
        parentStates.push(new VarStack(generator, types, this));
        parallelStacks.clear();
        labelEnds.clear();

        for (var label : labels) {
            parallelStacks.put(label, new ArrayDeque<>(currentStack));
        }
    }

    public void enteredLabel(String label) {
        currentLabel = label;
        if (labelEnds.containsValue(label)) {
            consolidateStates();
        } else {
            currentStack = parallelStacks.getOrDefault(label, currentStack);
        }
    }

    private void consolidateStates() {
        var operandStack = new ArrayDeque<StackEntry>();

        while (!currentStack.isEmpty()) {
            var phiEntries = new ArrayList<PhiEntry>();

            for (var entry : parallelStacks.entrySet()) {
                var stack = entry.getValue();

                var item = stack.removeFirst();
                phiEntries.add(new PhiEntry(item.pushedLabel(), item.variable()));
            }

            if (phiEntries.stream().map(PhiEntry::variable).distinct().count() == 1) {
                operandStack.push(new StackEntry(phiEntries.getFirst().label(), phiEntries.getFirst().variable()));
            } else {
                var type = phiEntries.stream()
                    .map(PhiEntry::variable)
                    .map(types::get)
                    .filter(Objects::nonNull)
                    .findFirst()
                    .orElse(LlvmType.Primitive.INT); // TODO: make stack accept typed values
                // TODO: load variables if needed

                var variable = generator.phi(type, phiEntries);
                operandStack.push(new StackEntry(currentLabel, variable));
                types.put(variable, type);
            }
        }

        var parentState = parentStates.pop();
        currentStack = operandStack;
        parallelStacks = parentState.parallelStacks;
        labelEnds = parentState.labelEnds;
    }

    public void endLabel(String currentLabel, String nextLabel) {
        if (parallelStacks.isEmpty()) return;

        labelEnds.put(currentLabel, nextLabel);
    }

    private record StackEntry(String pushedLabel, String variable) {
    }
}
