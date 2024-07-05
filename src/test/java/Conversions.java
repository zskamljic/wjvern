public final class Conversions {
    static int main() {
        double d = 1.0;
        float d2f = (float) d;
        printDouble(d2f);
        int d2i = (int) d;
        printInt(d2i);
        long d2l = (long) d;
        printLong(d2l);

        double f2d = d2f;
        printDouble(f2d);
        int f2i = (int) d2f;
        printInt(f2i);
        long f2l = (long) d2f;
        printLong(f2l);

        byte i2b = (byte) d2i;
        printInt(i2b);
        char i2c = (char) d2i;
        printInt(i2c);
        double i2d = d2i;
        printDouble(i2d);
        float i2f = (float) d2i;
        printDouble(i2f);
        long i2l = d2i;
        printLong(i2l);
        short i2s = (short) d2i;
        printInt(i2s);

        double l2d = d2l;
        printDouble(l2d);
        float l2f = (float) d2l;
        printDouble(l2f);
        int l2i = (int) d2l;
        printInt(l2i);

        return 0;
    }

    static void printInt(int value) {
        var intPattern = new byte[]{'%', 'd', '\n', '\0'};
        printf(intPattern, value);
    }

    static void printLong(long value) {
        var longPattern = new byte[]{'%', 'l', 'd', '\n', '\0'};
        printf(longPattern, value);
    }

    static void printDouble(double value) {
        var doublePattern = new byte[]{'%', 'f', '\n', '\0'};
        printf(doublePattern, value);
    }

    static native int printf(byte[] str, int... params);

    static native int printf(byte[] str, double... params);

    static native int printf(byte[] str, long... params);
}