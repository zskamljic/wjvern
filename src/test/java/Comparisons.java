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
        compareZero(0);
        compareZero(1);
        compareLong(0);
        compareLong(1);
        compareLong(-1);
        compareNull(null);
        compareNull(a);
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

    private static void compareZero(int value) {
        if (value == 0) {
            printOk(6);
        }
        if (value != 0) {
            printOk(7);
        }
        if (value < 0) {
            printOk(8);
        }
        if (value >= 0) {
            printOk(9);
        }
        if (value <= 0) {
            printOk(10);
        }
    }

    private static void compareLong(long l) {
        if (l == 0) {
            printOk(11);
        }
        if (l > 0) {
            printOk(12);
        }
        if (l < 0) {
            printOk(13);
        }
    }

    private static void compareNull(Comparisons o) {
        if (o == null) {
            printOk(14);
        }
        if (o != null) {
            printOk(15);
        }
    }

    private static void printOk(int count) {
        var c = (byte) ('0' + count);
        puts(new byte[]{'O', 'K', '#', c, '\0'});
    }

    static native int puts(byte[] str);
}
