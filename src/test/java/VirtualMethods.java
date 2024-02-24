public class VirtualMethods {
    int i;
    void doSomething() {
        printf(new byte[]{'m', 'e', 't', 'h', 'o', 'd', '\n', '\0'});
        i = 5;
    }

    static int main() {
        var instance = new VirtualMethods();
        instance.doSomething();
        return instance.i;
    }

    static native int printf(byte[] str, int... params);
}
