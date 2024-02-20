public class NativeMethods {
    static int main() {
        return puts(new byte[]{'H', 'e', 'l', 'l', 'o', '!', '\0'});
    }

    static native int puts(byte[] str);
}
