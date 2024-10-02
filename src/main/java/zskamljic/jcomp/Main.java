package zskamljic.jcomp;

import picocli.CommandLine;
import zskamljic.jcomp.llir.ClassBuilder;
import zskamljic.jcomp.llir.IrClassGenerator;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Stream;

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
            var buildDir = options.outputDirectory;
            if (!Files.exists(buildDir)) {
                Files.createDirectory(buildDir);
            }
            var resolver = new StdLibResolver(Path.of("stdlib"));
            var generator = new ClassBuilder(resolver, ClassFile.of().parse(options.inputClass), options.inputClass.getParent(), options.debug);

            var generatedFiles = generator.generate();

            var processes = ProcessBuilder.startPipeline(List.of(
                linkFiles(buildDir, generatedFiles),
                new ProcessBuilder("opt", "-S", "--O3"), // Optimize
                new ProcessBuilder("llc"), // Generate assembly
                compileAssembly(options.libraries)
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
                for (var generatedFile : generatedFiles.keySet()) {
                    //Files.deleteIfExists(buildDir.resolve(STR."\{generatedFile}.ll"));
                }
            }
        } catch (IOException | InterruptedException e) {
            System.err.println("Unable to parse class file " + options.inputClass + ": " + e.getMessage());
        }
    }

    private static ProcessBuilder compileAssembly(List<Path> libraries) {
        var items = new ArrayList<>(List.of("clang++", "-static", "-x", "assembler", "-"));
        libraries.removeIf(p -> p.getFileName().toString().isBlank());
        if (!libraries.isEmpty()) {
            var paths = new HashSet<Path>();
            var libs = new HashSet<String>();

            for (var library : libraries) {
                paths.add(library.toAbsolutePath().getParent());
                libs.add(library.getFileName()
                    .toString()
                    .replaceAll("^lib", "")
                    .replaceAll("\\.(so|a)$", ""));
            }
            libs.forEach(l -> items.add("-l" + l));
            paths.forEach(p -> items.add("-L" + p));
        }

        return new ProcessBuilder(items.toArray(new String[0]));
    }

    private static ProcessBuilder linkFiles(Path buildDir, Map<String, IrClassGenerator> files) {
        var command = new ArrayList<>(List.of("llvm-link", "-S"));
        files.entrySet()
            .stream()
            .map(e -> {
                var fileName = e.getKey() + ".ll";
                try {
                    var filePath = buildDir.resolve(fileName);
                    if (!Files.exists(filePath.getParent())) {
                        Files.createDirectories(filePath.getParent());
                    }
                    Files.writeString(filePath, e.getValue().generate());
                } catch (IOException ex) {
                    throw new IllegalStateException("Unable to write file", ex);
                }
                return fileName;
            })
            .map(buildDir::resolve)
            .map(Objects::toString)
            .forEach(command::add);

        Stream.of("stock_native.ll", "type_info.ll")
            .forEach(name -> {
                try (var input = Main.class.getResourceAsStream("/" + name)) {
                    if (input == null) throw new IllegalStateException("Unable to load " + name);

                    var output = buildDir.resolve(name);
                    try (var outputStream = Files.newOutputStream(output)) {
                        input.transferTo(outputStream);
                    }
                    command.add(output.toString());
                } catch (IOException e) {
                    throw new IllegalStateException("Unable to load " + name);
                }
            });

        return new ProcessBuilder(command.toArray(new String[0]));
    }
}