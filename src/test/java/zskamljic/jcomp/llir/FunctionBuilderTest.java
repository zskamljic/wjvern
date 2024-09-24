package zskamljic.jcomp.llir;

import org.junit.jupiter.api.Test;
import zskamljic.jcomp.registries.Registry;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;

class FunctionBuilderTest {
    @Test
    void compilesCoder() throws IOException {
        var stringClass = ClassFile.of().parse(Path.of("stdlib/classes/java/lang/String.class"));
        var coderMethod = stringClass.methods()
            .stream()
            .filter(m -> m.methodName().equalsString("coder"))
            .findFirst()
            .orElseThrow();

        var functionRegistry = new Registry(ignored -> Optional.empty(), ignored -> false);
        var functionBuilder = new FunctionBuilder(coderMethod, List.of("coder"), functionRegistry, false);

        var generated = functionBuilder.generate();

        assertEquals("""
            define i8 @"java/lang/String_coder()B"(%"java/lang/String"* %param.0) personality ptr @__gxx_personality_v0 {
              %local.0 = alloca %"java/lang/String"**
              store %"java/lang/String"* %param.0, %"java/lang/String"** %local.0
              br label %label0
            label0:
              ; %this entered scope under name %local.0
              ; Line 4911
              %1 = load i1, i1* @"java/lang/String_COMPACT_STRINGS"
              %2 = sext i1 %1 to i32
              %3 = icmp eq i32 %2, 0
              br i1 %3, label %label2, label %label3
            label3:
              %4 = load %"java/lang/String"*, %"java/lang/String"** %local.0
              %5 = getelementptr inbounds %"java/lang/String", %"java/lang/String"* %4, i32 0, i32 2
              %6 = load i8, i8* %5
              br label %label4
            label2:
              br label %label4
            label4:
              %7 = phi i8 [1, %label2], [%6, %label3]
              ret i8 %7
            label1:
              ; %this exited scope under name %local.0
              unreachable
            }""", generated);
    }
}