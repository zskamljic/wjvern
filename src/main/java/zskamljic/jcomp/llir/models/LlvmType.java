package zskamljic.jcomp.llir.models;

public sealed interface LlvmType {
    record Pointer(String type) implements LlvmType {

        @Override
        public String toString() {
            return type;
        }
    }

    record Array(int length, String type) implements LlvmType {
        @Override
        public String toString() {
            return STR."[\{length} x \{type}]";
        }
    }
}
