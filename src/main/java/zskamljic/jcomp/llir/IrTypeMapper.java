package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;

import java.lang.classfile.TypeKind;
import java.lang.constant.ClassDesc;
import java.util.Optional;

public class IrTypeMapper {
    private IrTypeMapper() {
        // Prevent instantiation
    }

    public static Optional<LlvmType> mapType(ClassDesc classDesc) {
        if (!classDesc.isPrimitive()) {
            return mapComplexType(classDesc);
        }
        return Optional.ofNullable(switch (classDesc.displayName()) {
            case "boolean" -> LlvmType.Primitive.BOOLEAN;
            case "double" -> LlvmType.Primitive.DOUBLE;
            case "float" -> LlvmType.Primitive.FLOAT;
            case "int" -> LlvmType.Primitive.INT;
            case "long" -> LlvmType.Primitive.LONG;
            case "void" -> LlvmType.Primitive.VOID;
            default -> {
                System.err.println(STR."Unsupported type: \{classDesc.displayName()}");
                yield null;
            }
        });
    }

    private static Optional<LlvmType> mapComplexType(ClassDesc classDesc) {
        if (classDesc.isArray()) {
            return Optional.of(LlvmType.Primitive.POINTER); // TODO: check if all arrays should use ptr
        }

        return Optional.of(new LlvmType.Declared(classDesc.displayName()));
    }

    public static Optional<LlvmType> mapType(TypeKind typeKind) {
        return Optional.ofNullable(switch (typeKind) {
            case ByteType -> LlvmType.Primitive.BYTE;
            case DoubleType -> LlvmType.Primitive.DOUBLE;
            case FloatType -> LlvmType.Primitive.FLOAT;
            case IntType -> LlvmType.Primitive.INT;
            default -> {
                System.err.println(STR."Unsupported type: \{typeKind.typeName()}");
                yield null;
            }
        });
    }
}
