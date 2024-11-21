package zskamljic.wjvern.llir.models;

import java.util.List;
import java.util.stream.Collectors;

public sealed interface AggregateType {
    LlvmType.Declared type();

    List<LlvmType> fields();

    record Defined(LlvmType.Declared type, List<LlvmType> fields) implements AggregateType {
        @Override
        public String toString() {
            var builder = new StringBuilder();
            builder.append(type).append(" = type { ");

            var fieldsString = fields.stream()
                //.map(String::valueOf)
                .map(f -> f instanceof LlvmType.Pointer ? "ptr" : f.toString())
                .collect(Collectors.joining(", "));
            builder.append(fieldsString);

            builder.append(" }");
            return builder.toString();
        }
    }

    record Opaque(LlvmType.Declared type) implements AggregateType {
        @Override
        public String toString() {
            return type+" = type opaque";
        }

        @Override
        public List<LlvmType> fields() {
            return List.of();
        }
    }
}
