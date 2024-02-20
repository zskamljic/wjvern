public class ForLoop {
    static int main() {
        for (int i = 0; i < 5; i++) {
            printf(new byte[]{'%', 'd', '\n', '\0'}, i);
        }
        return 0;
    }

    static native int printf(byte[] str, int... params);
}
