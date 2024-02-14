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
            return mapComplexType(classDesc);
        }
        return Optional.ofNullable(switch (classDesc.displayName()) {
            case "double", "float" -> classDesc.displayName();
            case "int" -> "i32";
            case "long" -> "i64";
            case "void" -> "void";
            default -> {
                System.err.println(STR."Unsupported type: \{classDesc.displayName()}");
                yield null;
            }
        });
    }

    private static Optional<String> mapComplexType(ClassDesc classDesc) {
        if (classDesc.isArray()) {
            return Optional.of("ptr"); // TODO: check if all arrays should use ptr
        }

        return Optional.empty();
    }

    public static Optional<String> mapType(TypeKind typeKind) {
        return Optional.ofNullable(switch (typeKind) {
            case ByteType -> "i8";
            case DoubleType -> "double";
            case FloatType -> "float";
            case IntType -> "i32";
            default -> {
                System.err.println(STR."Unsupported type: \{typeKind.typeName()}");
                yield null;
            }
        });
    }
}
