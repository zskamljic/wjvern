public class NativeVarArgMethods {
    static int main() {
        printf(new byte[]{'%', 'd', '\n', '\0'}, 1);
        printf(new byte[]{'%', 'f', '\n', '\0'}, 2f);
        printf(new byte[]{'%', 'f', '\n', '\0'}, 3.0);
        return 0;
    }

    static native int printf(byte[] str, int... params);

    static native int printf(byte[] str, float... params);

    static native int printf(byte[] str, double... params);
}
