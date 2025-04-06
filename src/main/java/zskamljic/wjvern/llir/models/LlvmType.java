package zskamljic.wjvern.llir.models;

import zskamljic.wjvern.llir.IrTypeMapper;
import zskamljic.wjvern.llir.Utils;

import java.lang.classfile.MethodModel;
import java.lang.constant.MethodTypeDesc;
import java.util.ArrayList;
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
            return "%" + Utils.escape(type);
        }

        @Override
        public boolean isReferenceType() {
            return true;
        }
    }

    record Function(LlvmType returnType, List<LlvmType> parameters, boolean isNative) implements LlvmType {
        public Function(String className, MethodModel method) {
            this(
                IrTypeMapper.mapType(method.methodTypeSymbol().returnType()),
                generateParameterList(className, method.methodTypeSymbol()),
                Utils.isNative(method)
            );
        }

        private static List<LlvmType> generateParameterList(String className, MethodTypeDesc methodTypeSymbol) {
            var parameterList = new ArrayList<LlvmType>();
            parameterList.add(new LlvmType.Pointer(new LlvmType.Declared(className)));
            for (int i = 0; i < methodTypeSymbol.parameterCount(); i++) {
                var parameter = methodTypeSymbol.parameterType(i);
                var type = IrTypeMapper.mapType(parameter);
                if (type.isReferenceType()) {
                    type = new Pointer(type);
                }
                parameterList.add(type);
            }
            return parameterList;
        }

        @Override
        public String toString() {
            return returnType + "(" + parameters.stream().map(Objects::toString).collect(Collectors.joining(", ")) + ")";
        }
    }

    record Global(String name) implements LlvmType {
        @Override
        public String toString() {
            return "@" + name;
        }
    }

    record NativeVarArgReturn(LlvmType returnType, List<LlvmType> parameter) implements LlvmType {
        @Override
        public String toString() {
            return returnType + "(" + parameter.stream().map(String::valueOf).collect(Collectors.joining(",")) + ",...)";
        }
    }

    record Pointer(LlvmType type) implements LlvmType {
        @Override
        public String toString() {
            return type.toString() + "*";
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
