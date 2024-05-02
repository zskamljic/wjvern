package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;

import java.lang.classfile.TypeKind;
import java.lang.constant.ClassDesc;

public class IrTypeMapper {
    private IrTypeMapper() {
        // Prevent instantiation
    }

    public static LlvmType mapType(ClassDesc classDesc) {
        if (!classDesc.isPrimitive()) {
            return mapComplexType(classDesc);
        }
        return switch (classDesc.displayName()) {
            case "boolean" -> LlvmType.Primitive.BOOLEAN;
            case "double" -> LlvmType.Primitive.DOUBLE;
            case "float" -> LlvmType.Primitive.FLOAT;
            case "int" -> LlvmType.Primitive.INT;
            case "long" -> LlvmType.Primitive.LONG;
            case "void" -> LlvmType.Primitive.VOID;
            default -> throw new IllegalArgumentException(STR."\{classDesc} type not supported yet");
        };
    }

    private static LlvmType mapComplexType(ClassDesc classDesc) {
        if (classDesc.isArray()) {
            return LlvmType.Primitive.POINTER; // TODO: check if all arrays should use ptr
        }

        return new LlvmType.Declared(classDesc.descriptorString()
            .replaceAll("^L", "")
            .replaceAll(";$", ""));
    }

    public static LlvmType.Primitive mapType(TypeKind typeKind) {
        return switch (typeKind) {
            case ByteType -> LlvmType.Primitive.BYTE;
            case DoubleType -> LlvmType.Primitive.DOUBLE;
            case FloatType -> LlvmType.Primitive.FLOAT;
            case IntType -> LlvmType.Primitive.INT;
            default -> LlvmType.Primitive.POINTER;
        };
    }
}
