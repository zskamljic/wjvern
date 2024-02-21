package zskamljic.jcomp;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import zskamljic.jcomp.llir.ClassBuilder;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class IrCodeTest {
    private static final Path BUILD_PATH = Path.of("testBuild");

    @AfterAll
    static void tearDown() throws IOException {
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
    }

    @ParameterizedTest
    @ValueSource(strings = {
        "Simple", "StaticFunctions", "NativeMethods", "NativeVarArgMethods", "ConstructorAndInstanceMethods",
        "VariableAssignment", "InstanceFields", "IfStatements", "ForLoop", "WhileLoop", "BasicMath"
    })
    void compilesSimple(String fileName) throws IOException {
        var classGenerator = new ClassBuilder(Path.of(STR."target/test-classes/\{fileName}.class"), true);

        if (!Files.exists(BUILD_PATH)) {
            Files.createDirectory(BUILD_PATH);
        }
        var result = classGenerator.generate(BUILD_PATH);

        var output = STR."\{fileName}.ll";
        assertEquals(List.of(output), result);

        try (var expectedInput = getClass().getResourceAsStream(STR."/\{fileName}.ll")) {
            assertNotNull(expectedInput);

            var expected = new String(expectedInput.readAllBytes(), StandardCharsets.UTF_8);
            var actual = Files.readString(BUILD_PATH.resolve(output));
            assertEquals(expected, actual);
        }
    }
}