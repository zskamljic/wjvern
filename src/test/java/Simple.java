public class Simple {
    int i;
    int j;
    float f;
    double d;
    boolean b;

    //    public static void main(String[] args) {
//        main();
//    }
    public Simple() {
        i = 1;
        f = 5;
        d = 7;
        b = false;
    }

    void doSomething() {
        if (!b) {
            b = true;
            j = 1;
        } else {
            print();
            j = 2;
        }
    }

    public static int main() {
        var instance = new Simple();
        instance.doSomething();
        printf(new byte[]{'j', ':', '%', 'd', '\n', '\0'}, instance.j);
        instance.doSomething();
        printf(new byte[]{'j', ':', '%', 'd', '\n', '\0'}, instance.j);
        printf(new byte[]{'%', 'd', '\n', '\0'}, instance.i);
        printf(new byte[]{'%', 'f', '\n', '\0'}, instance.f);
        printf(new byte[]{'%', 'f', '\n', '\0'}, instance.d);

        printf(new byte[]{'C', 'o', 'u', 'n', 't', 'i', 'n', 'g', '\n', '\0'});
        for (int i = 0; i < 5; i++) {
            printf(new byte[]{'%', 'd', '\n', '\0'}, i);
        }
        return instance.i + instance.j;
    }

    static int print() {
        puts(new byte[]{'H', 'e', 'l', 'l', 'o', '!', '\0'});
        return 1;
    }

    static native int puts(byte[] str);

    static native int printf(byte[] str, int... params);

    static native int printf(byte[] str, float... params);

    static native int printf(byte[] str, double... params);
}
