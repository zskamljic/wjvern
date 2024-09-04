package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.AggregateType;
import zskamljic.jcomp.llir.models.FunctionRegistry;
import zskamljic.jcomp.llir.models.LlvmType;

import java.lang.classfile.constantpool.StringEntry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

public class GlobalInitializer {
    private final Map<IrClassGenerator, List<StringEntry>> initializers = new HashMap<>();
    private final List<String> generatedInits = new ArrayList<>();

    public void addInitializableString(IrClassGenerator classGenerator, StringEntry index) {
        initializers.computeIfAbsent(classGenerator, ignored -> new ArrayList<>()).add(index);
    }

    public void finishInitialization(IrClassGenerator classGenerator) {
        if (!initializers.containsKey(classGenerator)) return;

        var initBuilder = new StringBuilder();
        if (!"java/lang/String".equals(classGenerator.getClassName())) {
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
        FunctionRegistry functionRegistry
    ) {
        if (generated.containsKey("__entrypoint")) return;

        var generator = new IrClassGenerator("__entrypoint", false, definitionMapper, functionRegistry);
        generated.put("__entrypoint", generator);
        generator.injectCode("""
            %0 = type { i32, ptr, ptr }
            @llvm.global_ctors = appending global [1 x %0] [%0 { i32 65535, ptr @__cxx_global_var_init, ptr null }]""");

        var initCode = new StringBuilder();
        initCode.append("define internal void @__cxx_global_var_init() section \".text.startup\" personality ptr @__gxx_personality_v0 {\n");
        for (var string : generatedInits) {
            // TODO: exception handling
            generator.injectCode("declare void " + string + "()");

            initCode.append("  ").append("call void ").append(string).append("()\n");
        }
        initCode.append("  ret void\n}");

        generator.injectCode("""
            declare i32 @"%1$s_main()I"()
            
            define i32 @main(i32 %%0, ptr %%1) {
                %%3 = call i32 @"%1$s_main()I"()
                ret i32 %%3
            }""".formatted(className));

        generator.injectCode("declare i32 @__gxx_personality_v0(...)");
        generator.injectCode(initCode.toString());
    }
}
