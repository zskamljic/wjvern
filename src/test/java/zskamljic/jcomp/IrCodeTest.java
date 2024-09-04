package zskamljic.jcomp;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import zskamljic.jcomp.llir.ClassBuilder;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class IrCodeTest {
    private static final StdLibResolver resolver = new StdLibResolver(Path.of("stdlib"));

    @ParameterizedTest
    @ValueSource(strings = {
        "Simple", "StaticFunctions", "NativeMethods", "NativeVarArgMethods", "ConstructorAndInstanceMethods",
        "VariableAssignment", "InstanceFields", "IfStatements", "ForLoop", "WhileLoop", "BasicMath", "VirtualMethods",
        "Inheritance", "Parameters", "Exceptions", "ExceptionsData", "Switch", "Comparisons", "FunctionOverloading",
        "ReturnReference", "ObjectArrays", "ReusedLocals", "ForEach", "Conversions", "StaticFields", "ReturnArray",
        "ReferenceFields", "Strings"
    })
    void generatesValid(String fileName) throws IOException {
        var classPath = Path.of("target/test-classes/");
        var classGenerator = new ClassBuilder(resolver, ClassFile.of().parse(classPath.resolve(fileName+".class")), classPath, false);

        var generatedFiles = classGenerator.generate();
        assertFalse(generatedFiles.isEmpty());

        for (var output : generatedFiles.entrySet()) {
            var name = output.getKey();
            if (name.startsWith("java/lang") || name.equals("__entrypoint")) {
                output.getValue().generate();
                continue;
            }

            var value = output.getValue();
            try (var expectedInput = getClass().getResourceAsStream("/"+name+".ll")) {
                assertNotNull(expectedInput, name+".ll was not found.");

                var expected = new String(expectedInput.readAllBytes(), StandardCharsets.UTF_8);
                assertEquals(expected, value.generate());
            }
        }
    }
}
