package zskamljic.wjvern.registries;

import zskamljic.wjvern.Blacklist;
import zskamljic.wjvern.llir.Utils;
import zskamljic.wjvern.llir.models.LlvmType;
import zskamljic.wjvern.llir.models.Vtable;
import zskamljic.wjvern.llir.models.VtableInfo;

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
    /**
     * Temporary separate loader used solely for static flags on methods, to be removed once
     * stdlib support is increased
     */
    private final ClassLoader stdLibLoader;
    private final Map<String, Integer> typeIds = new HashMap<>();
    private final Map<Integer, String> idsToType = new HashMap<>();
    private final Map<String, TypeInfo> typeInfos = new HashMap<>();

    public Registry(ClassLoader classLoader, ClassLoader stdLibLoader) {
        this.classLoader = classLoader;
        this.stdLibLoader = stdLibLoader;
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
        return Optional.ofNullable(vtables.get(ownerClass)).flatMap(v -> v.get(functionName, methodTypeDesc));
    }

    public boolean isStatic(MethodRefEntry method) {
        var owner = method.owner().name().stringValue();
        if (!methods.containsKey(owner)) {
            var ownerClass = classLoader.load(method.owner()).or(() -> stdLibLoader.load(method.owner()));
            return ownerClass.stream()
                .map(ClassModel::methods)
                .flatMap(Collection::stream)
                .filter(m -> m.methodName().equals(method.name()))
                .filter(m -> m.methodType().equals(method.type()))
                .anyMatch(m -> m.flags().has(AccessFlag.STATIC));
        }

        return methods.get(owner)
            .stream()
            .anyMatch(m -> m.flags().has(AccessFlag.STATIC) && Utils.methodName(owner, m).equals(Utils.methodName(method)));
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

    public void walk(ClassModel current) {
        walkClass(current);
        initArrayTypeInfo();
    }

    private void initArrayTypeInfo() {
        var typeInfo = new TypeInfo(new ArrayList<>(), List.of());
        typeInfo.types().add(typeInfos.size());
        typeInfo.types().add(typeInfos.get("java/lang/Object").types().getFirst());
        typeInfos.put("java_Array", typeInfo);
    }

    private void walkClass(ClassModel current) {
        var className = current.thisClass().name().stringValue();
        if (vtables.containsKey(className)) return;

        var vtable = new Vtable(className);
        handleSuperclass(current, vtable);
        handleMethods(current, className, vtable);
        vtables.put(className, vtable);

        var typeInfo = createTypeInfo(current, className);

        handleConstantPool(current);
        addInterfaceInfo(current, typeInfo);
    }

    private void handleSuperclass(ClassModel current, Vtable vtable) {
        var superclass = current.superclass();
        if (superclass.isEmpty()) return;

        var parentClass = classLoader.load(superclass.get()).filter(p -> Utils.isValidSuperclass(current, p));
        if (parentClass.isPresent()) {
            walkClass(parentClass.get());
            vtable.addAll(vtables.get(parentClass.get().thisClass().name().stringValue()));
        }
    }

    private void handleMethods(ClassModel current, String className, Vtable vtable) {
        current.methods()
            .stream()
            .filter(Predicate.not(Blacklist::isUnsupportedFunction))
            .forEach(method -> handleMethod(className, vtable, method));
    }

    private void handleMethod(String className, Vtable vtable, MethodModel method) {
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

    private TypeInfo createTypeInfo(ClassModel current, String className) {
        var typeId = typeIds.size();
        typeIds.put(className, typeId);
        idsToType.put(typeId, className);
        var typeInfo = new TypeInfo(new ArrayList<>(), new ArrayList<>());
        typeInfo.types().add(typeId);
        var superclass = current.superclass();
        if (superclass.filter(p -> isValidTypeInfoSuperclass(current, p)).isPresent()) {
            var parent = superclass.get().name().stringValue();
            var parentTypes = typeInfos.get(parent);
            if (parentTypes != null) {
                typeInfo.types().addAll(parentTypes.types());
                typeInfo.interfaces().addAll(parentTypes.interfaces());
            }
        }
        typeInfos.put(className, typeInfo);
        return typeInfo;
    }

    private boolean isValidTypeInfoSuperclass(ClassModel current, ClassEntry p) {
        return p.name().equalsString(EXCEPTION_NAME) || Utils.isValidSuperclass(current, classLoader.load(p).orElseThrow());
    }

    private void addInterfaceInfo(ClassModel current, TypeInfo typeInfo) {
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
    }

    private void handleConstantPool(ClassModel current) {
        for (var entry : current.constantPool()) {
            if (entry instanceof ClassEntry classEntry) {
                handleConstantPoolClass(classEntry);
            } else if (entry instanceof MethodRefEntry method) {
                var owner = method.owner();
                if (vtables.containsKey(owner.name().stringValue())) continue;

                handleConstantPoolClass(owner);
            }
        }
    }

    private void handleConstantPoolClass(ClassEntry classEntry) {
        var referencedClass = classLoader.load(classEntry);
        if (referencedClass.isPresent()) {
            walkClass(referencedClass.get());
        } else {
            vtables.put(classEntry.name().stringValue(), new Vtable(classEntry.name().stringValue()));
        }
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
        Optional<ClassModel> load(ClassEntry entry);
    }
}
