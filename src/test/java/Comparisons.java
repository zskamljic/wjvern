public final class Comparisons {
    static int main() {
        var a = new Comparisons();
        var b = new Comparisons();
        if (a == a) {
            printOk(0);
        }
        if (a != b) {
            printOk(1);
        }
        compare(1);
        return 0;
    }

    private static void compare(int value) {
        if (value == 1) {
            printOk(2);
        }
        if (value != 2) {
            printOk(3);
        }
        if (value < 2) {
            printOk(4);
        }
        if (2 > value) {
            printOk(5);
        }
    }

    private static void printOk(int count) {
        var c = (byte) ('1' + count);
        puts(new byte[]{'O', 'K', '#', c, '\0'});
    }

    static native int puts(byte[] str);
}
