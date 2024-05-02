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

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class IrCodeTest {
    private static final Path BUILD_PATH = Path.of("testBuild");
    private static final StdLibResolver resolver = new StdLibResolver(Path.of("stdlib"));

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
        "VariableAssignment", "InstanceFields", "IfStatements", "ForLoop", "WhileLoop", "BasicMath", "VirtualMethods",
        "Inheritance", "Parameters", "Exceptions", "ExceptionsData", "Switch", "Comparisons"
    })
    void generatesValid(String fileName) throws IOException {
        var classGenerator = new ClassBuilder(resolver, Path.of(STR."target/test-classes/\{fileName}.class"), true);

        if (!Files.exists(BUILD_PATH)) {
            Files.createDirectory(BUILD_PATH);
        }

        var generatedFiles = classGenerator.generate();
        assertFalse(generatedFiles.isEmpty());

        for (var output : generatedFiles.entrySet()) {
            var name = output.getKey();
            if (name.startsWith("java/lang")) {
                output.getValue().generate();
                continue;
            }

            var value = output.getValue();
            try (var expectedInput = getClass().getResourceAsStream(STR."/\{name}.ll")) {
                assertNotNull(expectedInput, STR."\{name}.ll was not found.");

                var expected = new String(expectedInput.readAllBytes(), StandardCharsets.UTF_8);
                assertEquals(expected, value.generate());
            }
        }
    }
}
