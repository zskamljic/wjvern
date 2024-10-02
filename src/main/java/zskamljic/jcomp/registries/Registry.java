package zskamljic.jcomp.registries;

import zskamljic.jcomp.llir.Utils;
import zskamljic.jcomp.llir.models.LlvmType;
import zskamljic.jcomp.llir.models.Vtable;
import zskamljic.jcomp.llir.models.VtableInfo;

import java.io.IOException;
import java.lang.classfile.ClassModel;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.MemberRefEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.constant.MethodTypeDesc;
import java.lang.reflect.AccessFlag;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.function.Predicate;

public class Registry {
    public static final String EXCEPTION_NAME = "java/lang/Exception";
    private final Map<String, Vtable> vtables = new HashMap<>();
    private final Map<String, Set<MethodModel>> methods = new HashMap<>();
    private final ClassLoader classLoader;
    private final Predicate<MethodModel> isUnsupportedFunction;
    private final Map<String, Integer> typeIds = new HashMap<>();
    private final Map<Integer, String> idsToType = new HashMap<>();
    private final Map<String, TypeInfo> typeInfos = new HashMap<>();

    public Registry(ClassLoader classLoader, Predicate<MethodModel> isUnsupportedFunction) {
        this.classLoader = classLoader;
        this.isUnsupportedFunction = isUnsupportedFunction;
        // TODO: remove when exception compiles
        vtables.put(EXCEPTION_NAME, new Vtable(EXCEPTION_NAME));
        methods.put(EXCEPTION_NAME, new HashSet<>());
        typeIds.put(EXCEPTION_NAME, 0);
        idsToType.put(0, EXCEPTION_NAME);
        typeInfos.put(EXCEPTION_NAME, new TypeInfo(List.of(), List.of()));
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
        walkClass(classModel);
    }

    private Vtable walkClass(ClassModel current) throws IOException {
        var className = current.thisClass().name().stringValue();
        if (vtables.containsKey(className)) return vtables.get(className);

        var vtable = new Vtable(className);
        if (current.superclass().isPresent()) {
            var parentClass = classLoader.load(current.superclass().get()).filter(p -> Utils.isValidSuperclass(current, p));
            if (parentClass.isPresent()) {
                var parent = walkClass(parentClass.get());
                vtable.addAll(parent);
            }
        }
        for (var method : current.methods()) {
            if (isUnsupportedFunction.test(method)) {
                continue;
            }
            if (Utils.isVirtual(method)) {
                var functionSignature = new LlvmType.Function(className, method);
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
        var typeId = typeIds.size();
        typeIds.put(className, typeId);
        idsToType.put(typeId, className);
        var typeInfo = new TypeInfo(new ArrayList<>(), new ArrayList<>());
        typeInfo.types().add(typeId);
        if (current.superclass().filter(p -> {
            try {
                return p.name().equalsString(EXCEPTION_NAME) || Utils.isValidSuperclass(current, classLoader.load(p).orElseThrow());
            } catch (IOException e) {
                System.err.println(e.getMessage());
                return false;
            }
        }).isPresent()) {
            var parent = current.superclass().get().name().stringValue();
            var parentTypes = typeInfos.get(parent);
            if (parentTypes != null) {
                typeInfo.types().addAll(parentTypes.types());
                typeInfo.interfaces().addAll(parentTypes.interfaces());
            }
        }
        typeInfos.put(className, typeInfo);

        for (var entry : current.constantPool()) {
            if (entry instanceof ClassEntry classEntry) {
                var referencedClass = classLoader.load(classEntry);
                if (referencedClass.isPresent()) {
                    walkClass(referencedClass.get());
                } else {
                    vtables.put(classEntry.name().stringValue(), new Vtable(classEntry.name().stringValue()));
                }
            } else if (entry instanceof MethodRefEntry method) {
                var owner = method.owner();
                if (vtables.containsKey(owner.name().stringValue())) continue;

                var referencedClass = classLoader.load(owner);
                if (referencedClass.isPresent()) {
                    walkClass(referencedClass.get());
                } else {
                    vtables.put(owner.name().stringValue(), new Vtable(owner.name().stringValue()));
                }
            }
        }
        current.interfaces()
            .stream()
            .map(i -> i.name().stringValue())
            .map(typeInfos::get)
            .filter(Objects::nonNull)
            .map(TypeInfo::types)
            .flatMap(Collection::stream)
            .distinct()
            .forEach(typeInfo.interfaces()::add);
        typeInfo.consolidateTypes();
        return vtable;
    }

    public boolean definesFunction(String className, VtableInfo vtableInfo) {
        return methods.getOrDefault(className, Set.of())
            .stream()
            .map(m -> "@" + Utils.methodName(className, m))
            .anyMatch(m -> m.equals(vtableInfo.functionName()));
    }

    public TypeInfo getTypeInfo(String className) {
        return typeInfos.get(className);
    }

    public List<String> interfacesOf(String className) {
        return Optional.ofNullable(typeInfos.get(className))
            .map(TypeInfo::interfaces)
            .stream()
            .flatMap(Collection::stream)
            .map(idsToType::get)
            .toList();
    }

    @FunctionalInterface
    public interface ClassLoader {
        Optional<ClassModel> load(ClassEntry entry) throws IOException;
    }
}
