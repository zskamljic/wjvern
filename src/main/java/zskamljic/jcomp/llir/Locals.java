package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;

import java.lang.classfile.instruction.LocalVariable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Predicate;

public class Locals {
    private final List<Local> variables = new ArrayList<>();
    private final Map<Integer, Local> activeLocals = new HashMap<>();
    private final IrMethodGenerator generator;
    private final Map<String, LlvmType> types;
    private final LabelGenerator labelGenerator;
    private final Predicate<String> parameterChecker;
    private final Set<String> allocatedLocals = new HashSet<>();

    public Locals(IrMethodGenerator generator, Map<String, LlvmType> types, LabelGenerator labelGenerator, Predicate<String> parameterChecker) {
        this.generator = generator;
        this.types = types;
        this.labelGenerator = labelGenerator;
        this.parameterChecker = parameterChecker;
    }

    public Local get(int slot) {
        return activeLocals.computeIfAbsent(slot, s -> {
            var name = STR."%local.\{s}";
            var local = new Local(name, LlvmType.Primitive.POINTER, s, null, null);
            if (!types.containsKey(name)) {
                generator.alloca(name, LlvmType.Primitive.POINTER);
                types.put(name, LlvmType.Primitive.POINTER);
            }
            return local;
        });
    }

    public void register(LocalVariable variable) {
        var rawName = variable.name().stringValue();
        var codeName = STR."%\{rawName}";

        var type = IrTypeMapper.mapType(variable.typeSymbol());

        if (type == LlvmType.Primitive.POINTER) {
            throw new IllegalArgumentException(STR."Locals of type \{type} not yet supported");
        }

        LlvmType varType;
        if (type instanceof LlvmType.Pointer || parameterChecker.test(rawName)) {
            varType = type;
        } else {
            varType = new LlvmType.Pointer(type);
        }

        variables.add(new Local(
            codeName,
            varType,
            variable.slot(),
            labelGenerator.getLabel(variable.startScope()),
            labelGenerator.getLabel(variable.endScope())
        ));
    }

    public void enteredLabel(String currentLabel) {
        activeLocals.values().removeIf(l -> currentLabel.equals(l.end()));
        variables.stream()
            .filter(v -> currentLabel.equals(v.start()))
            .forEach(v -> {
                if (activeLocals.containsKey(v.slot())) {
                    var variable = activeLocals.get(v.slot()).varName();
                    if (!(v.type() instanceof LlvmType.Pointer(LlvmType.Primitive _)) &&
                        !(v.type() instanceof LlvmType.Pointer(LlvmType.Array _)) &&
                        !(v.type() instanceof LlvmType.Pointer(LlvmType.SizedArray _))) {
                        variable = generator.load(v.type(), LlvmType.Primitive.POINTER, activeLocals.get(v.slot()).varName());
                    }
                    if (allocatedLocals.contains(v.varName())) {
                        var loaded = generator.load(((LlvmType.Pointer)v.type()).type(), LlvmType.Primitive.POINTER, variable);
                        generator.store(((LlvmType.Pointer)v.type()).type(), loaded, v.type(), v.varName());
                    } else {
                        allocatedLocals.add(v.varName());
                        generator.bitcast(v.varName(), LlvmType.Primitive.POINTER, variable, v.type());
                    }
                }
                var type = v.type();
                if (type instanceof LlvmType.Primitive && !parameterChecker.test(v.varName().substring(1))) {
                    type = new LlvmType.Pointer(type);
                }
                types.put(v.varName(), type);
                activeLocals.put(v.slot(), v);
            });
    }

    public boolean contains(String value) {
        return activeLocals.values().stream().anyMatch(v -> v.varName().equals(value));
    }
}
