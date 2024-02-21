public class WhileLoop {
    static int main() {
        int i = 10;
        while (i > 0) {
            printf(new byte[]{'%', 'd', '\n', '\0'}, i);
            i--;
        }
        return 0;
    }

    static native int printf(byte[] str, int... params);
}
