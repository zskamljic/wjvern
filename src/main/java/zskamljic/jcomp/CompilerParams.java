package zskamljic.jcomp;

import picocli.CommandLine;

import java.io.File;

public class CompilerParams {
    @CommandLine.Option(names = {"-d", "--debug"}, description = "Print debug info")
    boolean debug;

    @CommandLine.Parameters(paramLabel = "CLASS", description = "The class to compile")
    File inputClass;
}
