package zskamljic.jcomp;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.lang.classfile.CompoundElement;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.classfile.instruction.InvokeDynamicInstruction;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

public class Blacklist {
    private static final List<String> blacklistedFunctions;
    private static final Map<String, BlacklistClass> blacklistClasses;
    private static final List<String> supportedClasses;

    static {
        var objectMapper = new ObjectMapper();
        Items blacklist;
        try {
            var supportedClassesFile = Blacklist.class.getResource("/supported_classes.txt");
            if (supportedClassesFile != null) {
                supportedClasses = Files.readAllLines(Path.of(supportedClassesFile.getPath()));
            } else {
                supportedClasses = new ArrayList<>();
            }

            blacklist = objectMapper.readValue(
                Blacklist.class.getResourceAsStream("/unsupported_functions.json"),
                Items.class
            );
            blacklistedFunctions = blacklist.any().byName();
            blacklistClasses = blacklist.classes();
        } catch (IOException e) {
            throw new IllegalStateException("Unable to parse blacklist file", e);
        }
    }

    private Blacklist() {
        // Prevent instantiation
    }

    public static boolean isSupportedClass(String className) {
        return supportedClasses.contains(className);
    }

    public static boolean isUnsupportedFunction(MethodModel method) {
        return hasUnsupportedInstruction(method) || isBlacklisted(method);
    }

    private static boolean hasUnsupportedInstruction(MethodModel method) {
        return method.code()
            .stream()
            .flatMap(CompoundElement::elementStream)
            .anyMatch(InvokeDynamicInstruction.class::isInstance);
    }

    private static boolean isBlacklisted(MethodModel method) {
        return blacklistedFunctions.contains(method.methodName().stringValue()) ||
            isBlacklistedForClass(method);
    }

    private static boolean isBlacklistedForClass(MethodModel method) {
        var optionalBlacklist = method.parent()
            .map(p -> blacklistClasses.get(p.thisClass().name().stringValue()));
        if (optionalBlacklist.isEmpty()) return false;

        var blacklist = optionalBlacklist.get();
        return blacklist.byName().contains(method.methodName().stringValue()) ||
            blacklist.bySignature()
                .stream()
                .filter(s -> method.methodName().equalsString(s.name()))
                .anyMatch(s -> s.signatures().contains(method.methodType().stringValue()));
    }

    public static boolean hasUnsupportedType(MethodRefEntry method) {
        return Stream.concat(Stream.of(method.typeSymbol().returnType()), method.typeSymbol().parameterList().stream())
            .map(c -> c.packageName().replace(".", "/") + "/" + c.displayName())
            .anyMatch(Blacklist::isSupportedClass);
    }

    record Items(BlacklistClass any, Map<String, BlacklistClass> classes) {
        @JsonCreator
        Items(@JsonProperty("*") BlacklistClass any) {
            this(any, new HashMap<>());
        }

        @JsonAnySetter
        void setField(String name, BlacklistClass value) {
            classes.put(name, value);
        }
    }

    record BlacklistClass(List<String> byName, List<Signature> bySignature) {
        BlacklistClass {
            if (byName == null) byName = new ArrayList<>();
            if (bySignature == null) bySignature = new ArrayList<>();
        }
    }

    record Signature(String name, List<String> signatures) {
        Signature {
            if (signatures == null) signatures = new ArrayList<>();
        }
    }
}
