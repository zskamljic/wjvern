package zskamljic.jcomp.llir.models;

import zskamljic.jcomp.llir.Utils;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public sealed interface LlvmType {
    default boolean isReferenceType() {
        return false;
    }

    record Array(LlvmType type) implements LlvmType {
        @Override
        public String toString() {
            return "%java_Array";
        }

        @Override
        public boolean equals(Object obj) {
            if (obj instanceof Array(var otherType)) {
                return type.equals(otherType);
            } else if (obj instanceof SizedArray(var _, var otherType)) {
                return type.equals(otherType);
            }
            return false;
        }

        @Override
        public boolean isReferenceType() {
            return true;
        }
    }

    record SizedArray(int length, LlvmType type) implements LlvmType {
        @Override
        public String toString() {
            return "%java_Array";
        }

        @Override
        public boolean equals(Object obj) {
            if (obj instanceof Array(var otherType)) {
                return type.equals(otherType);
            } else if (obj instanceof SizedArray(var _, var otherType)) {
                return type.equals(otherType);
            }
            return false;
        }

        @Override
        public boolean isReferenceType() {
            return true;
        }
    }

    record Declared(String type) implements LlvmType {
        @Override
        public String toString() {
            return STR."%\{Utils.escape(type)}";
        }

        @Override
        public boolean isReferenceType() {
            return true;
        }
    }

    record Function(LlvmType returnType, List<LlvmType> parameters) implements LlvmType {
        @Override
        public String toString() {
            return STR."\{returnType}(\{parameters.stream().map(Objects::toString).collect(Collectors.joining(", "))})";
        }
    }

    record Global(String name) implements LlvmType {
        @Override
        public String toString() {
            return STR."@\{name}";
        }
    }

    record NativeVarArgReturn(LlvmType returnType, List<LlvmType> parameter) implements LlvmType {
        @Override
        public String toString() {
            return STR."\{returnType}(\{parameter.stream().map(String::valueOf).collect(Collectors.joining(","))},...)";
        }
    }

    record Pointer(LlvmType type) implements LlvmType {
        @Override
        public String toString() {
            return STR."\{type.toString()}*";
        }
    }

    enum Primitive implements LlvmType {
        BOOLEAN,
        VOID,
        POINTER,
        // Signed integers
        BYTE,
        SHORT,
        INT,
        LONG,

        // Floating points
        FLOAT,
        DOUBLE;

        public static LlvmType select(String value) {
            if (value.contains(".")) return DOUBLE;
            return LONG;
        }

        public boolean isFloatingPoint() {
            return switch (this) {
                case FLOAT, DOUBLE -> true;
                default -> false;
            };
        }

        @Override
        public String toString() {
            return switch (this) {
                case VOID -> "void";
                case BOOLEAN -> "i1";
                case POINTER -> "ptr";
                case BYTE -> "i8";
                case SHORT -> "i16";
                case INT -> "i32";
                case LONG -> "i64";
                case FLOAT -> "float";
                case DOUBLE -> "double";
            };
        }
    }
}
