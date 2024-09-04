package zskamljic.jcomp.llir.models;

import zskamljic.jcomp.llir.IrTypeMapper;
import zskamljic.jcomp.llir.Utils;

import java.io.IOException;
import java.lang.classfile.ClassModel;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.MemberRefEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.constant.MethodTypeDesc;
import java.lang.reflect.AccessFlag;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Predicate;

public class FunctionRegistry {
    private final Map<String, Vtable> vtables = new HashMap<>();
    private final Map<String, Set<MethodModel>> methods = new HashMap<>();
    private final ClassLoader classLoader;
    private final Predicate<MethodModel> isUnsupportedFunction;

    public FunctionRegistry(ClassLoader classLoader, Predicate<MethodModel> isUnsupportedFunction) {
        this.classLoader = classLoader;
        this.isUnsupportedFunction = isUnsupportedFunction;
        // TODO: remove when exception compiles
        vtables.put("java/lang/Exception", new Vtable("java/lang/Exception"));
        methods.put("java/lang/Exception", new HashSet<>());
    }

    public List<LlvmType.Declared> getRequiredTypes(String className) {
        if (!vtables.containsKey(className)) return List.of();

        return vtables.get(className).requiredTypes();
    }

    public List<VtableInfo> getVirtualFunctions(String className) {
        if (!vtables.containsKey(className)) return List.of();

        return vtables.get(className)
            .stream()
            .toList();
    }

    public Optional<VtableInfo> getVirtual(String ownerClass, String functionName, MethodTypeDesc methodTypeDesc) {
        return vtables.get(ownerClass).get(functionName, methodTypeDesc);
    }

    public boolean isNative(String className, MemberRefEntry methodRefEntry) {
        return methods.getOrDefault(className, Set.of())
            .stream()
            // TODO: perhaps also add an annotation to specify functions linked from C?
            .filter(method -> method.flags().has(AccessFlag.NATIVE) && method.flags().has(AccessFlag.STATIC))
            .anyMatch(method -> Utils.methodName(className, method).equals(Utils.methodName(methodRefEntry)));
    }

    public boolean isNativeVarArg(String className, MemberRefEntry methodRefEntry) {
        return methods.getOrDefault(className, Set.of())
            .stream()
            .filter(method -> method.flags().has(AccessFlag.VARARGS) && method.flags().has(AccessFlag.STATIC))
            .anyMatch(method -> Utils.methodName(className, method).equals(Utils.methodName(methodRefEntry)));
    }

    public void walk(ClassModel classModel) throws IOException {
        generateVtable(classModel);
    }

    private Vtable generateVtable(ClassModel current) throws IOException {
        var className = current.thisClass().name().stringValue();
        if (vtables.containsKey(className)) return vtables.get(className);

        var vtable = new Vtable(className);
        if (current.superclass().isPresent()) {
            var parentClass = classLoader.load(current.superclass().get());
            if (parentClass.isPresent()) {
                var parent = generateVtable(parentClass.get());
                vtable.addAll(parent);
            }
        }
        for (var method : current.methods()) {
            if (isUnsupportedFunction.test(method)) {
                continue;
            }
            if (Utils.isVirtual(method)) {
                var returnType = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
                var parameterList = generateParameterList(className, method.methodTypeSymbol());
                var functionSignature = new LlvmType.Function(returnType, parameterList);
                var functionName = "@" + Utils.methodName(className, method);
                vtable.put(
                    method.methodName().stringValue(),
                    method.methodTypeSymbol(),
                    functionSignature,
                    functionName
                );
            }
            methods.computeIfAbsent(className, ignored -> new HashSet<>()).add(method);
        }
        vtables.put(className, vtable);

        for (var entry : current.constantPool()) {
            if (entry instanceof ClassEntry classEntry) {
                var referencedClass = classLoader.load(classEntry);
                if (referencedClass.isPresent()) {
                    generateVtable(referencedClass.get());
                } else {
                    vtables.put(classEntry.name().stringValue(), new Vtable(classEntry.name().stringValue()));
                }
            } else if (entry instanceof MethodRefEntry method) {
                var owner = method.owner();
                if (vtables.containsKey(owner.name().stringValue())) continue;

                var referencedClass = classLoader.load(owner);
                if (referencedClass.isPresent()) {
                    generateVtable(referencedClass.get());
                } else {
                    vtables.put(owner.name().stringValue(), new Vtable(owner.name().stringValue()));
                }
            }
        }
        return vtable;
    }

    private static List<LlvmType> generateParameterList(String className, MethodTypeDesc methodTypeSymbol) {
        var parameterList = new ArrayList<LlvmType>();
        parameterList.add(new LlvmType.Pointer(new LlvmType.Declared(className)));
        for (int i = 0; i < methodTypeSymbol.parameterCount(); i++) {
            var parameter = methodTypeSymbol.parameterType(i);
            var type = IrTypeMapper.mapType(parameter);
            parameterList.add(type);
        }
        return parameterList;
    }

    @FunctionalInterface
    public interface ClassLoader {
        Optional<ClassModel> load(ClassEntry entry) throws IOException;
    }
}
