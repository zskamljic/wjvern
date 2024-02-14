public class Simple {
    int i;
    int j;
    float f;
    double d;
    //    public static void main(String[] args) {
//        main();
//    }
    public Simple() {
        i = 1;
        f = 5;
        d = 7;
        print();
    }

    void doSomething() {
        j = 2;
        print();
    }

    public static int main() {
        var instance = new Simple();
        instance.doSomething();
        call2();
        printf(new byte[]{'%', 'd', '\n', '\0'}, instance.i);
        printf(new byte[]{'%', 'f', '\n', '\0'}, instance.f);
        printf(new byte[]{'%', 'f', '\n', '\0'}, instance.d);
        return instance.i + instance.j;
    }

    static int print() {
        puts(new byte[]{'H', 'e', 'l', 'l', 'o', '!', '\0'});
        return 1;
    }

    static void call2() {
        print();
    }

    static native int puts(byte[] str);

    static native int printf(byte[] str, int... params);

    static native int printf(byte[] str, float... params);

    static native int printf(byte[] str, double... params);
}
