package zskamljic.jcomp.llir.models;

import zskamljic.jcomp.llir.IrMethodGenerator;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public interface CodeEntry {
    record BinaryOperation(
        String newVar,
        IrMethodGenerator.Operator operator,
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
                case SHL -> "shl";
                case ASHR -> "ashr";
                case AND -> "and";
                case OR -> "or";
                case XOR -> "xor";
            };

            return STR."\{newVar} = \{op} \{type} \{operand1}, \{operand2}";
        }
    }

    record Alloca(String varName, LlvmType type, String size) implements CodeEntry {
        public Alloca(String varName, LlvmType type) {
            this(varName, type, null);
        }

        @Override
        public String toString() {
            if (size != null) {
                return STR."\{varName} = alloca \{type}, \{LlvmType.Primitive.INT} \{size}";
            }
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

    record Call(
        String returnVar,
        LlvmType returnType,
        String functionName,
        List<Parameter> parameters
    ) implements CodeEntry {
        @Override
        public String toString() {
            String invocation = "";
            if (returnType != LlvmType.Primitive.VOID) {
                invocation += STR."\{returnVar} = ";
            }
            var global = !functionName.startsWith("%");
            return STR."\{invocation}call \{returnType} \{global ? '@' : ""}\{functionName}(\{parameters.stream()
                .map(p -> {
                    if (p.isReturn()) {
                        return STR."ptr sret(\{p.type()}) \{p.name()}";
                    }
                    return STR."\{p.type()} \{p.name()}";
                })
                .collect(Collectors.joining(", "))})";
        }
    }

    record Comment(String comment) implements CodeEntry {
        @Override
        public String toString() {
            return STR."; \{comment}";
        }
    }

    record Compare(String varName, IrMethodGenerator.Condition condition, LlvmType type, String a, String b) implements CodeEntry {
        @Override
        public String toString() {
            var comparisonType = switch (type) {
                case LlvmType.Primitive p when !p.isFloatingPoint() -> "icmp";
                case LlvmType.Primitive.POINTER -> "icmp";
                default -> throw new IllegalArgumentException(STR."Comparison between types of \{type} not yet supported");
            };
            var cond = switch (condition) {
                case EQUAL -> "eq";
                case GREATER -> "sgt";
                case GREATER_EQUAL -> "sge";
                case LESS -> "slt";
                case LESS_EQUAL -> "sle";
                case NOT_EQUAL -> "ne";
            };

            return STR."\{varName} = \{comparisonType} \{cond} \{type} \{a}, \{b}";
        }
    }

    record ExtractValue(String varName, String composite, String source, int index) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{varName} = extractvalue \{composite} \{source}, \{index}";
        }
    }

    record FloatingPointExtend(String newName, String varName) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = fpext float \{varName} to double";
        }
    }

    record FloatingPointToSignedInt(String newName, LlvmType.Primitive source, String varName, LlvmType.Primitive target) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = fptosi \{source} \{varName} to \{target}";
        }
    }

    record FloatingPointTruncate(String newName, LlvmType.Primitive source, String varName, LlvmType.Primitive target) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = fptrunc \{source} \{varName} to \{target}";
        }
    }

    record GetElementByPointer(
        String variableName,
        LlvmType targetType,
        LlvmType sourceType,
        String source,
        List<String> indices
    ) implements CodeEntry {
        @Override
        public String toString() {
            var line = STR."\{variableName} = getelementptr inbounds \{targetType}, \{sourceType} \{source}";
            if (!indices.isEmpty()) {
                line += STR.", \{indices.stream()
                    .map(i -> STR."i32 \{i}")
                    .collect(Collectors.joining(", "))}";
            }
            return line;
        }
    }

    record Invoke(
        String returnVar,
        LlvmType returnType,
        String functionName,
        List<Parameter> parameters,
        String next,
        String unwind
    ) implements CodeEntry {
        @Override
        public String toString() {
            String invocation = "";
            if (returnType != LlvmType.Primitive.VOID) {
                invocation += STR."\{returnVar} = ";
            }
            var global = !functionName.startsWith("%");
            return STR."\{invocation}invoke \{returnType} \{global ? '@' : ""}\{functionName}(\{parameters.stream()
                .map(p -> {
                    if (p.isReturn()) {
                        return STR."ptr sret(\{p.type()}) \{p.name()}";
                    }
                    return STR."\{p.type()} \{p.name()}";
                })
                .collect(Collectors.joining(", "))}) to label %\{next} unwind label %\{unwind}";
        }
    }

    record Label(String label) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{label}:";
        }
    }

    record LandingPad(String returnVar, List<LlvmType.Global> types) implements CodeEntry {
        @Override
        public String toString() {
            if (types == null) {
                return STR."\{returnVar} = landingpad { ptr, i32 } cleanup";
            }
            var catcher = STR."\{returnVar} = landingpad { ptr, i32 }";
            catcher += types.stream()
                .map(t -> STR." catch ptr \{t}")
                .collect(Collectors.joining());
            return catcher;
        }
    }

    record Load(String newName, LlvmType targetType, LlvmType sourceType, String variableName) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = load \{targetType}, \{sourceType} \{variableName}";
        }
    }

    record Negate(String newName, LlvmType.Primitive type, String variable) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = fneg \{type} \{variable}";
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

    record SignedExtend(String newName, LlvmType originalType, String source, LlvmType targetType) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = sext \{originalType} \{source} to \{targetType}";
        }
    }

    record SignedToFloatingPoint(String newName, LlvmType source, String varName, LlvmType target) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = sitofp \{source} \{varName} to \{target}";
        }
    }

    record SignedTruncate(String newName, LlvmType.Primitive source, String varName, LlvmType.Primitive target) implements CodeEntry {
        @Override
        public String toString() {
            return STR."\{newName} = trunc \{source} \{varName} to \{target}";
        }
    }

    record Store(LlvmType type, String value, LlvmType targetType, String varName) implements CodeEntry {
        @Override
        public String toString() {
            return STR."store \{type} \{value}, \{targetType} \{varName}";
        }
    }

    record Switch(String variable, String defaultCase, List<Map.Entry<Integer, String>> cases) implements CodeEntry {
        @Override
        public String toString() {
            return STR."switch i32 \{variable}, label %\{defaultCase} [" + cases.stream()
                .map(c -> STR."i32 \{c.getKey()}, label %\{c.getValue()}")
                .collect(Collectors.joining(" ")) + "]";
        }
    }

    record Unreachable() implements CodeEntry {
        @Override
        public String toString() {
            return "unreachable";
        }
    }
}
