package zskamljic.jcomp.llir.models;

import zskamljic.jcomp.llir.Utils;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public sealed interface LlvmType {

    record Array(int length, LlvmType type) implements LlvmType {
        @Override
        public String toString() {
            return STR."[\{length} x \{type}]";
        }
    }

    record Declared(String type) implements LlvmType {
        @Override
        public String toString() {
            return STR."%\{Utils.escape(type)}";
        }
    }

    record Function(LlvmType returnType, List<LlvmType> parameters) implements LlvmType {
        @Override
        public String toString() {
            return STR."\{returnType}(\{parameters.stream().map(Objects::toString).collect(Collectors.joining(", "))})";
        }
    }

    record Global(String name) {
        @Override
        public String toString() {
            return STR."@\{name}";
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
