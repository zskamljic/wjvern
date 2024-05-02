package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;
import java.util.Map;

public class SwitchStates {
    private final Deque<SwitchState> states = new ArrayDeque<>();
    private final IrMethodGenerator generator;
    private final Map<String, LlvmType> types;
    private Deque<String> lastStack;

    public SwitchStates(IrMethodGenerator generator, Map<String, LlvmType> types) {
        this.generator = generator;
        this.types = types;
    }

    public void add(String switchVar, String defaultCase, List<String> cases) {
        var allCases = new ArrayList<>(cases);
        allCases.add(defaultCase);
        states.add(new SwitchState(switchVar, allCases));
    }

    public void changedLabel(String currentLabel, Deque<String> stack) {
        if (states.isEmpty()) {
            lastStack = new ArrayDeque<>(stack);
            return;
        }

        var state = states.peekFirst();
        if (state.remainingLabels().remove(currentLabel) && !stack.equals(lastStack) && !stack.isEmpty()) {
            var pushedValue = stack.pop();
            LlvmType type;
            if (pushedValue.startsWith("%")) {
                type = LlvmType.Primitive.POINTER;
            } else {
                type = LlvmType.Primitive.select(pushedValue);
            }
            types.put(state.varName(), new LlvmType.Pointer(type));
            generator.store(type, pushedValue, LlvmType.Primitive.POINTER, state.varName());
            stack.push(state.varName());
        }
        if (state.remainingLabels().isEmpty()) {
            states.pop();
            while (state.varName().equals(stack.peekFirst())) {
                stack.pop();
            }
            stack.push(state.varName());
        }
        lastStack = new ArrayDeque<>(stack);
    }

    private record SwitchState(String varName, List<String> remainingLabels) {
    }
}
