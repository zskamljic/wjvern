public class Switch {
    static int switchFunc(int value) {
        // tableswitch
        return switch (value) {
            case 1 -> 5;
            case 2 -> 4;
            case 3 -> 3;
            case 4 -> 2;
            default -> 1;
        };
    }

    static int switchFunc2(int value) {
        // lookupswitch
        return switch (value) {
            case 1 -> 5;
            case 10 -> 50;
            case 100 -> 500;
            default -> 3;
        };
    }

    static int main() {
        return switchFunc2(switchFunc(3));
    }
}
