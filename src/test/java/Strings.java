public final class Strings {
    static int main() {
        var string = "hello\n\0";
        var bytes = string.getBytes();
        printInt(bytes.length);
        puts(bytes);
        printInt(string.length());
        puts(string.getBytes());
        return 0;
    }

    static void printInt(int i) {
        printf(new byte[]{'%', 'd', '\n', '\0'}, i);
    }

    static native int printf(byte[] str, int... params);

    static native int puts(byte[] str);
}
