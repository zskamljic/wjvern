package zskamljic.jcomp.llir.models;

import zskamljic.jcomp.llir.IrCodeGenerator;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public interface CodeEntry {
    record BinaryOperation(
        String newVar,
        IrCodeGenerator.Operator operator,
        LlvmType.Primitive type,
        String operand1,
        String operand2
    ) implements CodeEntry {
        @Override
        public String toString() {
            var isFloatingPoint = type == LlvmType.Primitive.FLOAT || type == LlvmType.Primitive.DOUBLE;
            var op = switch (operator) {
                case ADD -> isFloatingPoint ? "fadd" : "add";
                case DIV -> isFloatingPoint ? "fdiv" : "sdiv";
                case MUL -> isFloatingPoint ? "fmul" : "mul";
                case SUB -> isFloatingPoint ? "fsub" : "sub";
            };

            return STR."\{newVar} = \{op} \{type} \{operand1}, \{operand2}";
        }
    }

    record Alloca(String varName, LlvmType type) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{varName} = alloca \{type}";
        }
    }

    record Bitcast(String newVar, LlvmType oldType, String source, LlvmType newType) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newVar} = bitcast \{oldType} \{source} to \{newType}";
        }
    }

    sealed interface Branch extends CodeEntry {
        record Bool(String varName, String ifTrue, String ifFalse) implements Branch {
            @Override
            public String toString() {
                return STR."br i1 \{varName}, label %\{ifTrue}, label %\{ifFalse}";
            }
        }

        record Label(String label) implements Branch {
            @Override
            public String toString() {
                return STR."br label %\{label}";
            }
        }
    }

    record Comment(String comment) implements CodeEntry {
        @Override
        public String toString() {
            return STR."; \{comment}";
        }
    }

    record Compare(String varName, IrCodeGenerator.Condition condition, LlvmType type, String a, String b) implements CodeEntry {
        @Override
        public String toString() {
            var comparisonType = switch (type) {
                case LlvmType.Primitive p when p == LlvmType.Primitive.INT -> "icmp";
                default -> throw new IllegalArgumentException(STR."Comparison between types of \{type} not yet supported");
            };
            var cond = switch (condition) {
                case GREATER_EQUAL -> "sge";
                case LESS_EQUAL -> "sle";
            };

            return STR."\{varName} = \{comparisonType} \{cond} \{type} \{a}, \{b}";
        }
    }

    record FloatingPointExtend(String newName, String varName) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = fpext float \{varName} to double";
        }
    }

    record GetElementByPointer(String variableName, LlvmType targetType, LlvmType sourceType, String source, String index) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{variableName} = getelementptr inbounds \{targetType}, \{sourceType} \{source}, i64 0, i32 \{index}";
        }
    }

    record Invoke(
        String returnVar,
        LlvmType returnType,
        String functionName,
        List<Map.Entry<String, LlvmType>> parameters
    ) implements CodeEntry {
        @Override
        public String toString() {
            String invocation = "";
            if (returnType != LlvmType.Primitive.VOID) {
                invocation += STR."\{returnVar} = ";
            }
            var global = !functionName.startsWith("%");
            return STR."\{invocation}call \{returnType} \{global ? '@' : ""}\{functionName}(\{parameters.stream()
                .map(p -> STR."\{p.getValue()} \{p.getKey()}")
                .collect(Collectors.joining(", "))})";
        }
    }

    record Label(String label) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{label}:";
        }
    }

    record Load(String newName, LlvmType targetType, LlvmType sourceType, String variableName) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = load \{targetType}, \{sourceType} \{variableName}";
        }
    }

    record Return(LlvmType type, String variable) implements CodeEntry {
        @Override
        public String toString() {
            if (type == LlvmType.Primitive.VOID) {
                return STR."ret \{type}";
            }
            return STR."ret \{type} \{variable}";
        }
    }

    record SignedExtend(String newName, LlvmType originalType, String targetType, String source) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = sext \{originalType} \{source} to \{targetType}";
        }
    }

    record Store(LlvmType type, String value, LlvmType targetType, String varName) implements CodeEntry {
        @Override
        public String toString() {
            return STR."store \{type} \{value}, \{targetType} \{varName}";
        }
    }
}
