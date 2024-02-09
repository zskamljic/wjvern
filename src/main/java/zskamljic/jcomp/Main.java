package zskamljic.jcomp;

import picocli.CommandLine;
import zskamljic.jcomp.llir.ClassBuilder;

import java.io.IOException;
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
            var generator = new ClassBuilder(options.inputClass, options.debug);
            var files = generator.generate();
            if (files.isEmpty()) {
                System.err.println("Failed to generate IR code, aborting");
                return;
            }

            var processes = ProcessBuilder.startPipeline(List.of(
                linkFiles(files),
                new ProcessBuilder("opt", "-S", "--O3"), // Optimize
                new ProcessBuilder("llc"), // Generate assembly
                new ProcessBuilder("clang", "-x", "assembler", "-") // Compile
            ));
            if (!options.debug) {
                for (var file : files) {
                    Files.delete(Path.of(file));
                }
            }
            for (var process : processes) {
                try (var error = process.getErrorStream()) {
                    var errorData = error.readAllBytes();
                    var errorString = new String(errorData, StandardCharsets.UTF_8);
                    if (!errorString.isBlank()) {
                        System.err.println(errorString);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println(STR."Unable to parse class file \{options.inputClass}: \{e.getMessage()}");
        }
    }

    private static ProcessBuilder linkFiles(List<String> files) throws IOException {
        var command = new ArrayList<>(List.of("llvm-link", "-S"));
        command.addAll(files);
        return new ProcessBuilder(command.toArray(new String[0]));
    }
}