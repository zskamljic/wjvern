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
        var functionBuilder = new FunctionBuilder(coderMethod, List.of("coder"), functionRegistry, true);

        var generated = functionBuilder.generate();

        assertEquals("""
            define i8 @"java/lang/String_coder()B"(%"java/lang/String"* %local.0) personality ptr @__gxx_personality_v0 {
              ; LocalVariable[name=this, slot=0, type=Ljava/lang/String;]
              br label %label0
            label0:
              ; %this entered scope under name %local.0
              ; LineNumber[line=4862]
              ; Line 4862
              ; Field[OP=GETSTATIC, field=java/lang/String.COMPACT_STRINGS:Z]
              %1 = load i1, i1* @"java/lang/String_COMPACT_STRINGS"
              ; Branch[OP=IFEQ]
              %2 = sext i1 %1 to i32
              %3 = icmp eq i32 %2, 0
              br i1 %3, label %label2, label %label3
            label3:
              ; Load[OP=ALOAD_0, slot=0]
              ; Field[OP=GETFIELD, field=java/lang/String.coder:B]
              %4 = getelementptr inbounds %"java/lang/String", %"java/lang/String"* %local.0, i32 0, i32 1
              %5 = load i8, i8* %4
              ; Branch[OP=GOTO]
              br label %label4
            label2:
              ; UnboundIntrinsicConstantInstruction[op=ICONST_1]
              br label %label4
            label4:
              %6 = phi i8 [1, %label2], [%5, %label3]
              ; Return[OP=IRETURN]
              ret i8 %6
            label1:
              ; %this exited scope under name %local.0
              unreachable
            }""", generated);
    }
}