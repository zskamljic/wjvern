package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.AggregateType;
import zskamljic.jcomp.registries.Registry;
import zskamljic.jcomp.llir.models.LlvmType;

import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.StringEntry;
import java.lang.reflect.AccessFlag;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.function.Predicate;

public class GlobalInitializer {
    private final Map<IrClassGenerator, List<StringEntry>> initializers = new HashMap<>();
    private final List<String> generatedInits = new ArrayList<>();

    public void addInitializableString(IrClassGenerator classGenerator, StringEntry index) {
        initializers.computeIfAbsent(classGenerator, ignored -> new ArrayList<>()).add(index);
    }

    public void finishInitialization(IrClassGenerator classGenerator) {
        if (!initializers.containsKey(classGenerator)) return;

        var initBuilder = new StringBuilder();
        if (!classGenerator.getClassName().startsWith("java/lang/String")) {
            initBuilder.append("declare void @\"java/lang/String_<init>([BB)V\"(ptr, ptr, i8) personality ptr @__gxx_personality_v0\n");
        }
        initBuilder.append("define void @\"").append(classGenerator.getClassName()).append("_var_init\"() personality ptr @__gxx_personality_v0 {\n");

        int locals = 1;
        int labels = 0;
        var exitLabel = "handlerLabel";
        for (var string : initializers.get(classGenerator)) {
            var nextLabel = "label." + labels++;
            // TODO: use proper type when invoking the constructor
            initBuilder.append("  invoke void @\"java/lang/String_<init>([BB)V\"(ptr @string.")
                .append(string.index())
                .append(", %java_Array* @string.array.")
                .append(string.index()).append(", i8 0) to label %")
                .append(nextLabel).append(" unwind label %")
                .append(exitLabel).append("\n")
                .append(nextLabel).append(":\n");
        }
        initBuilder.append("  ret void\n")
            .append(exitLabel).append(":\n")
            .append("  %").append(locals++).append(" = landingpad { ptr, i32 } cleanup\n")
            .append("  %").append(locals++).append(" = extractvalue { ptr, i32 } %").append(locals - 2).append(", 0\n")
            .append("  %").append(locals++).append(" = extractvalue { ptr, i32 } %").append(locals - 3).append(", 1\n")
            .append("  %").append(locals++).append(" = insertvalue { ptr, i32 } poison, ptr %").append(locals - 3).append(", 0\n")
            .append("  %").append(locals++).append(" = insertvalue { ptr, i32 } %").append(locals - 2).append(", i32 %").append(locals - 3).append(", 1\n")
            .append("  resume { ptr, i32 } %").append(locals - 1).append("\n");

        initBuilder.append("}");

        classGenerator.injectCode(initBuilder.toString());
        generatedInits.add("@\"" + classGenerator.getClassName() + "_var_init\"");
    }

    public void generateEntryPoint(
        String className,
        Map<String, IrClassGenerator> generated,
        Function<LlvmType.Declared, AggregateType> definitionMapper,
        Registry registry
    ) {
        if (generated.containsKey("__entrypoint")) return;

        var generator = new IrClassGenerator("__entrypoint", false, definitionMapper, registry);
        generated.put("__entrypoint", generator);

        var stringDefinition = definitionMapper.apply(new LlvmType.Declared("java/lang/String"));
        generator.injectCode(stringDefinition.toString());

        generator.injectCode("""
            %0 = type { i32, ptr, ptr }
            @llvm.global_ctors = appending global [1 x %0] [%0 { i32 65535, ptr @__cxx_global_var_init, ptr null }]
            
            @"java/lang/String_COMPACT_STRINGS" = external global i1"""); // TODO: remove once string clinit is enabled and working

        var initCode = new StringBuilder();
        initCode.append("define internal void @__cxx_global_var_init() section \".text.startup\" personality ptr @__gxx_personality_v0 {\n");
        for (var string : generatedInits) {
            // TODO: exception handling
            generator.injectCode("declare void " + string + "()");

            initCode.append("  ").append("call void ").append(string).append("()\n");
        }
        generator.injectCode("declare void @\"java/lang/String_<init>([BB)V\"(ptr, ptr, i8) personality ptr @__gxx_personality_v0");
        generator.injectCode("declare i64 @strlen(ptr)"); // TODO: use size based on platform
        initCode.append("""
              store i1 1, i1* @"java/lang/String_COMPACT_STRINGS"
              ret void
            }
            """);

        generateMain(className, generated, generator);

        generator.injectCode("declare i32 @__gxx_personality_v0(...)");
        generator.injectCode(initCode.toString());
    }

    private void generateMain(String className, Map<String, IrClassGenerator> generated, IrClassGenerator generator) {
        var mainMethod = generated.get(className)
            .getMethods()
            .stream()
            .filter(m -> m.methodName().equalsString("main"))
            .filter(m -> m.methodTypeSymbol().parameterCount() < 2)
            .filter(m -> m.methodTypeSymbol()
                .parameterList()
                .stream()
                .noneMatch(Predicate.not(c -> "[Ljava/lang/String;".equals(c.descriptorString()))))
            .min(this::tieredMains)
            .orElseThrow(() -> new IllegalArgumentException("No main method found"));

        var mainBuilder = new StringBuilder()
            .append(Utils.methodDefinition(className, mainMethod)).append("\n\n")
            .append("define i32 @main(i32 %0, ptr %1) {\n");

        String returnValue;
        if (mainMethod.methodTypeSymbol().parameterCount() > 0) {
            mainBuilder.append("""
                  %3 = sub i32 %0, 1
                  %4 = alloca %java_Array
                  %5 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 0
                  store i32 %3, i32* %5
                  %6 = alloca %"java/lang/String", i32 %3
                  %7 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
                  store ptr %6, ptr %7
                
                  %8 = alloca i32
                  store i32 0, i32* %8
                  br label %condition
                
                condition:
                  %9 = load i32, i32* %8
                  %10 = icmp slt i32 %9, %3
                  br i1 %10, label %next, label %end
                
                next:
                  %11 = add i32 %9, 1
                  %12 = getelementptr inbounds ptr, ptr %1, i32 %11
                  %13 = load ptr, ptr %12
                  %14 = call i64 @strlen(ptr %13)
                  %15 = trunc i64 %14 to i32
                  %16 = alloca %java_Array
                  %17 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 0
                  store i32 %15, i32* %17
                  %18 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
                  store ptr %13, ptr %18
                  %19 = alloca %"java/lang/String"
                  call void @"java/lang/String_<init>([BB)V"(%"java/lang/String"* %19, %java_Array* %16, i8 0)
                  %20 = getelementptr inbounds %"java/lang/String", ptr %6, i32 %9
                  store %"java/lang/String"* %19, ptr %20
                  br label %increment
                
                increment:
                  %21 = add nsw i32 %9, 1
                  store i32 %21, i32* %8
                  br label %condition
                
                end:
                """);

            mainBuilder.append("  call void @").append(Utils.methodName(className, mainMethod)).append("(%java_Array* %4)\n");

            returnValue = "0";
        } else {
            mainBuilder.append("  %3 = call i32 @").append(Utils.methodName(className, mainMethod)).append("()\n");
            returnValue = "%3";
        }

        mainBuilder.append("  ret i32 ").append(returnValue).append("\n}");
        generator.injectCode(mainBuilder.toString());
    }

    private int tieredMains(MethodModel left, MethodModel right) {
        if (left.flags().has(AccessFlag.STATIC) && !right.flags().has(AccessFlag.STATIC)) return -1;
        if (right.flags().has(AccessFlag.STATIC) && !left.flags().has(AccessFlag.STATIC)) return 1;

        return Integer.compare(right.methodTypeSymbol().parameterCount(), left.methodTypeSymbol().parameterCount());
    }
}
