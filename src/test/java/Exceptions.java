public class Exceptions {
    static int main() {
        try {
            throw new Exception();
        } catch (Exception e) {
            return 1;
        } finally {
            print();
        }
    }

    static void print() {
        puts(new byte[]{'H', 'e', 'l', 'l', 'o', '!', '\0'});
    }

    static native int puts(byte[] str);
}
