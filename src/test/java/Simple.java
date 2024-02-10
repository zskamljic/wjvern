public class Simple {
    int i;
    int j;

    //    public static void main(String[] args) {
//        main();
//    }
    public Simple() {
        i = 1;
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
}
