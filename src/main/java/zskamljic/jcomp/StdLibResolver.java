package zskamljic.jcomp;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

public class StdLibResolver {
    private static final Path MODULES_DIR = Path.of(System.getProperty("java.home"))
        .resolve("jmods");
    private final Path output;

    public StdLibResolver(Path output) {
        this.output = output;
        if (Files.isDirectory(output)) {
            try {
                Files.createDirectories(output);
            } catch (IOException e) {
                throw new IllegalStateException(e);
            }
        }
    }

    public ClassModel resolve(String className) {
        var targetFile = output.resolve("classes")
            .resolve(STR."\{className}.class");

        if (!Files.exists(targetFile)) {
            extractModule();
        }
        var classFile = ClassFile.of();
        try {
            return classFile.parse(targetFile);
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
    }

    private void extractModule() {
        try {
            var process = new ProcessBuilder(
                "jmod", "extract", "--dir", output.toString(), MODULES_DIR.resolve("java.base.jmod").toString()
            ).start();
            var input = process.getInputStream();
            process.waitFor();
            System.out.println(new String(input.readAllBytes(), StandardCharsets.UTF_8));
        } catch (IOException | InterruptedException e) {
            throw new IllegalStateException(e.getMessage());
        }
    }
}
