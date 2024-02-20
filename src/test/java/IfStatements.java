public class IfStatements {
    int i;
    boolean b = false;

    void doSomething() {
        if (!b) {
            b = true;
            i = 1;
        } else {
            i = 2;
        }
    }

    static int main() {
        var instance = new IfStatements();
        instance.doSomething();
        printf(new byte[]{'j', ':', '%', 'd', '\n', '\0'}, instance.i);
        instance.doSomething();
        printf(new byte[]{'j', ':', '%', 'd', '\n', '\0'}, instance.i);
        return 0;
    }

    static native int printf(byte[] str, int... params);
}
