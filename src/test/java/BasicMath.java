public class BasicMath {
    static int main() {
        float f = 1f;
        f += 2f;
        f /= 3f;
        f *= 4f;
        f -= 1f;
        printf(new byte[]{'%', 'f', '\n', '\0'}, f);

        double d = 1.0;
        d += 2.0;
        d /= 3.0;
        d *= 4.0;
        d -= 1.0;
        printf(new byte[]{'%', 'f', '\n', '\0'}, d);

        int i = 1;
        i += 2;
        i /= 3;
        i *= 4;
        i -= 1;
        return i;
    }

    static native int printf(byte[] str, float... params);

    static native int printf(byte[] str, double... params);
}
