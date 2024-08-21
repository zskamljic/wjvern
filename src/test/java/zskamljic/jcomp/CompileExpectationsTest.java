package zskamljic.jcomp;

import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.fail;

class CompileExpectationsTest {
    @TempDir
    private Path tempDir;

    @ParameterizedTest
    @ValueSource(strings = {
        "Simple", "StaticFunctions", "NativeMethods", "NativeVarArgMethods", "ConstructorAndInstanceMethods",
        "VariableAssignment", "InstanceFields", "IfStatements", "ForLoop", "WhileLoop", "BasicMath", "VirtualMethods",
        "Inheritance", "Parameters", "Exceptions", "ExceptionsData", "Switch", "Comparisons", "FunctionOverloading",
        "ReturnReference", "ObjectArrays", "ReusedLocals", "ForEach", "Conversions", "StaticFields", "ReturnArray",
        "ReferenceFields", "Strings"
    })
    void compileAndVerifyOutput(String fileName) throws IOException, InterruptedException {
        Main.main(new String[]{STR."target/test-classes/\{fileName}.class", "-o", tempDir.toString(), "-d"});

        var process = new ProcessBuilder("./a.out").start();
        try (
            var expectedOutput = getClass().getResourceAsStream(STR."/\{fileName}.out");
            var actualReader = process.inputReader()
        ) {
            assertNotNull(expectedOutput);

            var expectedReader = new BufferedReader(new InputStreamReader(expectedOutput));

            var expectedCode = Integer.parseInt(expectedReader.readLine());
            var actualCode = process.waitFor();

            if (expectedCode != actualCode) {
                var output = new StringBuilder();
                String line;
                do {
                    line = actualReader.readLine();
                    if (line != null) output.append(line).append("\n");
                } while (line != null);
                try (var errorReader = process.errorReader()) {
                    do {
                        line = errorReader.readLine();
                        if (line != null) output.append(line).append("\n");
                    } while (line != null);
                }
                fail(STR."""
                        Output code mismatch, expected \{expectedCode}, got \{actualCode}
                        Output:
                        \{output}""");
            }

            String expected;
            String actual;
            int line = 2;
            do {
                expected = expectedReader.readLine();
                actual = actualReader.readLine();

                assertEquals(expected, actual, STR."Line \{line}");
                line++;
            } while (expected != null && actual != null);
        }
    }
}
