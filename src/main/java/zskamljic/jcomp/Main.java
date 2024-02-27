package zskamljic.jcomp;

import picocli.CommandLine;
import zskamljic.jcomp.llir.ClassBuilder;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        var options = new CompilerParams();
        var commandLine = new CommandLine(options);
        try {
            commandLine.parseArgs(args);
        } catch (CommandLine.ParameterException e) {
            commandLine.usage(System.out);
            return;
        }

        try {
            var buildDir = Path.of("build");
            if (!Files.exists(buildDir)) {
                Files.createDirectory(buildDir);
            }
            var generator = new ClassBuilder(options.inputClass, options.debug);

            try (var output = new PrintWriter(new FileOutputStream(buildDir.resolve("IR.ll").toFile()))) {
                generator.generate(output, buildDir);
            }

            var processes = ProcessBuilder.startPipeline(List.of(
                linkFiles(buildDir, "IR.ll"),
                new ProcessBuilder("opt", "-S", "--O3"), // Optimize
                new ProcessBuilder("llc"), // Generate assembly
                new ProcessBuilder("clang", "-x", "assembler", "-") // Compile
            ));
            for (var process : processes) {
                process.waitFor();
                try (var error = process.getErrorStream()) {
                    var errorData = error.readAllBytes();
                    var errorString = new String(errorData, StandardCharsets.UTF_8);
                    if (!errorString.isBlank()) {
                        System.err.println(errorString);
                    }
                }
            }
            if (!options.debug) {
                Files.deleteIfExists(buildDir.resolve("IR.ll"));
            }
        } catch (IOException | InterruptedException e) {
            System.err.println(STR."Unable to parse class file \{options.inputClass}: \{e.getMessage()}");
        }
    }

    private static ProcessBuilder linkFiles(Path buildDir, String file) throws IOException {
        var command = new ArrayList<>(List.of("llvm-link", "-S"));
        command.add(buildDir.resolve(file).toString());
        return new ProcessBuilder(command.toArray(new String[0]));
    }
}