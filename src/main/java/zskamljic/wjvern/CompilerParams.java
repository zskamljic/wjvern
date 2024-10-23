package zskamljic.wjvern;

import picocli.CommandLine;

import java.nio.file.Path;
import java.util.List;

public class CompilerParams {
    @CommandLine.Option(names = {"-d", "--debug"}, description = "Print debug info")
    boolean debug;

    @CommandLine.Parameters(paramLabel = "CLASS", description = "The class to compile")
    Path inputClass;

    @CommandLine.Option(names = {"-o", "--output"}, description = "Output directory", defaultValue = "build")
    Path outputDirectory;

    @CommandLine.Option(names = {"-l"}, description = "Link library", arity = "1..*", defaultValue = "")
    List<Path> libraries;
}
