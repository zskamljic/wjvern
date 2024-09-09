package zskamljic.jcomp.llir;

import org.junit.jupiter.api.Test;
import zskamljic.jcomp.llir.models.FunctionRegistry;

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

        var functionRegistry = new FunctionRegistry(ignored -> Optional.empty(), ignored -> false);
        var functionBuilder = new FunctionBuilder(coderMethod, List.of("coder"), functionRegistry, false);

        var generated = functionBuilder.generate();

        assertEquals("""
            define i8 @"java/lang/String_coder()B"(%"java/lang/String"* %local.0) personality ptr @__gxx_personality_v0 {
            label0:
              ; %this entered scope under name %local.0
              ; Line 4911
              %0 = load i1, i1* @"java/lang/String_COMPACT_STRINGS"
              %1 = sext i1 %0 to i32
              %2 = icmp eq i32 %1, 0
              br i1 %2, label %label2, label %label3
            label3:
              %3 = getelementptr inbounds %"java/lang/String", %"java/lang/String"* %local.0, i32 0, i32 1
              %4 = load i8, i8* %3
              br label %label4
            label2:
              br label %label4
            label4:
              %5 = phi i8 [1, %label2], [%4, %label3]
              ret i8 %5
            label1:
              ; %this exited scope under name %local.0
              unreachable
            }""", generated);
    }
}