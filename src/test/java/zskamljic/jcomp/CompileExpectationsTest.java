package zskamljic.jcomp;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class CompileExpectationsTest {
    private static final Path BUILD_PATH = Path.of("integrationBuild");

    @AfterEach
    void tearDown() throws IOException {
        Files.walkFileTree(BUILD_PATH, new SimpleFileVisitor<>() {
            @Override
            public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
                Files.delete(dir);
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                Files.delete(file);
                return FileVisitResult.CONTINUE;
            }
        });
        Files.deleteIfExists(BUILD_PATH);
        Files.deleteIfExists(Path.of("a.out"));
    }

    @ParameterizedTest
    @ValueSource(strings = {
        "Simple", "StaticFunctions", "NativeMethods", "NativeVarArgMethods", "ConstructorAndInstanceMethods",
        "VariableAssignment", "InstanceFields", "IfStatements", "ForLoop", "WhileLoop", "BasicMath", "VirtualMethods",
        "Inheritance", "Parameters", "Exceptions", "ExceptionsData", "Switch"
    })
    void compileAndVerifyOutput(String fileName) throws IOException, InterruptedException {
        Main.main(new String[]{STR."target/test-classes/\{fileName}.class", "-o", BUILD_PATH.toString()});

        var process = new ProcessBuilder("./a.out").start();
        try (
            var expectedOutput = getClass().getResourceAsStream(STR."/\{fileName}.out");
            var actualReader = process.inputReader()
        ) {
            assertNotNull(expectedOutput);

            var expectedReader = new BufferedReader(new InputStreamReader(expectedOutput));

            var expectedCode = Integer.parseInt(expectedReader.readLine());
            var actualCode = process.waitFor();

            assertEquals(expectedCode, actualCode);

            String expected;
            String actual;
            do {
                expected = expectedReader.readLine();
                actual = actualReader.readLine();

                assertEquals(expected, actual);
            } while (expected != null && actual != null);
        }
    }
}
