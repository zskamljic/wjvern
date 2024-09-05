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

            return newVar + " = " + op + " " + type + " " + operand1 + ", " + operand2;
        }
    }

    record Alloca(String varName, LlvmType type, String size) implements CodeEntry {
        public Alloca(String varName, LlvmType type) {
            this(varName, type, null);
        }

        @Override
        public String toString() {
            if (size != null) {
                return varName + " = alloca " + type + ", " + LlvmType.Primitive.INT + " " + size;
            }
            return varName + " = alloca " + type;
        }
    }

    record Bitcast(String newVar, LlvmType oldType, String source, LlvmType newType) implements CodeEntry {
        @Override
        public String toString() {
            return newVar + " = bitcast " + oldType + " " + source + " to " + newType;
        }
    }

    sealed interface Branch extends CodeEntry {
        record Bool(String varName, String ifTrue, String ifFalse) implements Branch {
            @Override
            public String toString() {
                return "br i1 " + varName + ", label %" + ifTrue + ", label %" + ifFalse;
            }
        }

        record Label(String label) implements Branch {
            @Override
            public String toString() {
                return "br label %" + label;
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
                invocation += returnVar + " = ";
            }
            var global = !functionName.startsWith("%");
            return invocation + "call " + returnType + " " + (global ? '@' : "") + functionName + "(" + parameters.stream()
                .map(p -> {
                    if (p.isReturn()) {
                        return "ptr sret(" + p.type() + ") " + p.name();
                    }
                    return p.type() + " " + p.name();
                })
                .collect(Collectors.joining(", ")) + ")";
        }
    }

    record Comment(String comment) implements CodeEntry {
        @Override
        public String toString() {
            return "; " + comment;
        }
    }

    record Compare(String varName, IrMethodGenerator.Condition condition, LlvmType type, String a,
                   String b) implements CodeEntry {
        @Override
        public String toString() {
            var comparisonType = switch (type) {
                case LlvmType.Primitive p when !p.isFloatingPoint() -> "icmp";
                case LlvmType.Primitive.POINTER -> "icmp";
                default ->
                    throw new IllegalArgumentException("Comparison between types of " + type + " not yet supported ");
            };
            var cond = switch (condition) {
                case EQUAL -> "eq";
                case GREATER -> "sgt";
                case GREATER_EQUAL -> "sge";
                case LESS -> "slt";
                case LESS_EQUAL -> "sle";
                case NOT_EQUAL -> "ne";
            };

            return varName + " = " + comparisonType + " " + cond + " " + type + " " + a + ", " + b;
        }
    }

    record ExtractValue(String varName, String composite, String source, int index) implements CodeEntry {
        @Override
        public String toString() {
            return varName + " = extractvalue " + composite + " " + source + ", " + index;
        }
    }

    record FloatingPointExtend(String newName, String varName) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = fpext float " + varName + " to double";
        }
    }

    record FloatingPointToSignedInt(String newName, LlvmType.Primitive source, String varName,
                                    LlvmType.Primitive target) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = fptosi " + source + " " + varName + " to " + target;
        }
    }

    record FloatingPointTruncate(String newName, LlvmType.Primitive source, String varName,
                                 LlvmType.Primitive target) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = fptrunc " + source + " " + varName + " to " + target;
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
            var line = variableName + " = getelementptr inbounds " + targetType + ", " + sourceType + " " + source;
            if (!indices.isEmpty()) {
                line += ", " + indices.stream()
                    .map(i -> "i32 " + i)
                    .collect(Collectors.joining(", "));
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
                invocation += returnVar + " = ";
            }

            var global = !functionName.startsWith("%");
            return invocation + "invoke " + returnType + " " + (global ? '@' : "") + functionName + "(" + parameters.stream()
                .map(p -> {
                    if (p.isReturn()) {
                        return "ptr sret(" + p.type() + ")" + p.name();
                    }
                    return p.type() + " " + p.name();
                })
                .collect(Collectors.joining(", ")) + ") to label %" + next + " unwind label %" + unwind;
        }
    }

    record Label(String label) implements CodeEntry {
        @Override
        public String toString() {
            return label + ":";
        }
    }

    record LandingPad(String returnVar, List<LlvmType.Global> types) implements CodeEntry {
        @Override
        public String toString() {
            if (types == null) {
                return returnVar + " = landingpad { ptr, i32 } cleanup";
            }

            var catcher = returnVar + " = landingpad { ptr, i32 }";
            catcher += types.stream()
                .map(t -> " catch ptr " + t)
                .collect(Collectors.joining());
            return catcher;
        }
    }

    record Load(String newName, LlvmType targetType, LlvmType sourceType, String variableName) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = load " + targetType + ", " + sourceType + " " + variableName;
        }
    }

    record Negate(String newName, LlvmType.Primitive type, String variable) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = fneg " + type + " " + variable;
        }
    }

    record Phi(String newName, LlvmType type, List<PhiEntry> alternatives) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = phi " + type + " " + alternatives.stream()
                .map(a -> "[" + a.variable() + ", %" + a.label() + "]")
                .collect(Collectors.joining(", "));
        }
    }

    record Return(LlvmType type, String variable) implements CodeEntry {
        @Override
        public String toString() {
            if (type == LlvmType.Primitive.VOID) {
                return "ret " + type;
            }
            return "ret " + type + " " + variable;
        }
    }

    record SignedExtend(String newName, LlvmType originalType, String source,
                        LlvmType targetType) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = sext " + originalType + " " + source + " to " + targetType;
        }
    }

    record SignedToFloatingPoint(String newName, LlvmType source, String varName,
                                 LlvmType target) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = sitofp " + source + " " + varName + " to " + target;
        }
    }

    record SignedTruncate(String newName, LlvmType.Primitive source, String varName,
                          LlvmType.Primitive target) implements CodeEntry {
        @Override
        public String toString() {
            return newName + " = trunc " + source + " " + varName + " to " + target;
        }
    }

    record Store(LlvmType type, String value, LlvmType targetType, String varName) implements CodeEntry {
        @Override
        public String toString() {
            return "store " + type + " " + value + ", " + targetType + " " + varName;
        }
    }

    record Switch(String variable, String defaultCase, List<Map.Entry<Integer, String>> cases) implements CodeEntry {
        @Override
        public String toString() {
            return "switch i32 " + variable + ", label %" + defaultCase + " [" + cases.stream()
                .map(c -> "i32 " + c.getKey() + ", label %" + c.getValue())
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
