package zskamljic.jcomp.llir;

import java.lang.classfile.TypeKind;
import java.lang.constant.ClassDesc;
import java.util.Optional;

public class IrTypeMapper {
    private IrTypeMapper() {
        // Prevent instantiation
    }

    public static Optional<String> mapType(ClassDesc classDesc) {
        if (!classDesc.isPrimitive()) {
            return Optional.empty();
        }
        return Optional.ofNullable(switch (classDesc.displayName()) {
            case "int" -> "i32";
            case "void" -> "void";
            default -> {
                System.err.println(STR."Unsupported type: \{classDesc.displayName()}");
                yield null;
            }
        });
    }
}
