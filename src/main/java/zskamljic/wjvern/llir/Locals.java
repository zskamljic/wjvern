package zskamljic.wjvern.llir;

import zskamljic.wjvern.llir.models.LlvmType;
import zskamljic.wjvern.llir.models.Local;

import java.lang.classfile.instruction.LocalVariable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Predicate;

public class Locals {
    public static final String LOCAL_PREFIX = "%local.";
    public static final String PARAM_PREFIX = "%param.";
    private final List<Local> variables = new ArrayList<>();
    private final Map<Integer, Local> activeLocals = new HashMap<>();
    private final IrMethodGenerator generator;
    private final Map<String, LlvmType> types;
    private final LabelGenerator labelGenerator;
    private final Predicate<String> parameterChecker;

    public Locals(IrMethodGenerator generator, Map<String, LlvmType> types, LabelGenerator labelGenerator, Predicate<String> parameterChecker) {
        this.generator = generator;
        this.types = types;
        this.labelGenerator = labelGenerator;
        this.parameterChecker = parameterChecker;
    }

    public Local get(int slot) {
        return activeLocals.computeIfAbsent(slot, s -> {
            var name = LOCAL_PREFIX + s;
            var local = new Local(name, LlvmType.Primitive.POINTER, s, null, null);
            if (!types.containsKey(name)) {
                if (parameterChecker.test("param." + slot)) {
                    var paramType = types.get(PARAM_PREFIX + slot);
                    var type = new LlvmType.Pointer(paramType);
                    generator.alloca(name, type);
                    generator.store(paramType, PARAM_PREFIX + slot, type, name);
                    types.put(name, type);
                } else {
                    generator.alloca(name, LlvmType.Primitive.POINTER);
                    types.put(name, LlvmType.Primitive.POINTER);
                }
            }
            return local;
        });
    }

    public void register(LocalVariable variable) {
        var rawName = variable.name().stringValue();
        var codeName = "%" + rawName;

        var type = IrTypeMapper.mapType(variable.typeSymbol());
        if (!(type instanceof LlvmType.Primitive)) {
            type = new LlvmType.Pointer(type);
        }

        if (parameterChecker.test("param." + variable.slot())) {
            generator.alloca(LOCAL_PREFIX + variable.slot(), new LlvmType.Pointer(type));
            generator.store(type, PARAM_PREFIX + variable.slot(), new LlvmType.Pointer(type), LOCAL_PREFIX + variable.slot());
        }
        type = new LlvmType.Pointer(type);

        variables.add(new Local(
            codeName,
            type,
            variable.slot(),
            labelGenerator.getLabel(variable.startScope()),
            labelGenerator.getLabel(variable.endScope())
        ));
    }

    public void enteredLabel(String currentLabel) {
        activeLocals.values().removeIf(l -> {
            var removable = currentLabel.equals(l.end());
            if (removable) {
                generator.comment(l.codeName() + " exited scope under name " + l.varName());
            }
            return removable;
        });
        variables.stream()
            .filter(v -> currentLabel.equals(v.start()))
            .forEach(v -> {
                var type = v.type();
                types.put(v.varName(), type);
                generator.comment(v.codeName() + " entered scope under name " + v.varName());
                activeLocals.put(v.slot(), v);
            });
    }
}
