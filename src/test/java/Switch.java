public class Switch {
    static int switchFunc(int value) {
        return switch (value) {
            case 1 -> 5;
            case 2 -> 4;
            case 3 -> 3;
            case 4 -> 2;
            default -> 1;
        };
    }

    static int main() {
        return switchFunc(3);
    }
}
