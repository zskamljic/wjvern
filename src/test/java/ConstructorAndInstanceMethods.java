public class ConstructorAndInstanceMethods {
    public ConstructorAndInstanceMethods() {
        printf(new byte[]{'C', 'o', 'n', 's', 't', 'r', 'u', 'c', 't', 'o', 'r', '\n', '\0'});
    }

    final void method() {
        printf(new byte[]{'m', 'e', 't', 'h', 'o', 'd', '\n', '\0'});
    }

    static int main() {
        new ConstructorAndInstanceMethods().method();

        return 0;
    }

    static native int printf(byte[] str, int... params);
}
