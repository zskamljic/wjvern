package zskamljic.jcomp;

import picocli.CommandLine;

import java.io.File;

public class CompilerParams {
    @CommandLine.Option(names = {"-d", "--dirty"}, description = "Do not cleanup intermediate files")
    boolean dirty;

    @CommandLine.Parameters(paramLabel = "CLASS", description = "The class to compile")
    File inputClass;
}
