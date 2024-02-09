public class Simple {
    int i;
//    public static void main(String[] args) {
//        main();
//    }
    public Simple() {
        //i = 0;
        print();
    }

    void doSomething() {
        //i = 1;
        print();
    }

    public static int main() {
        var instance = new Simple();
        instance.doSomething();
        call2();
        return 0;
    }

    static int print() {
        puts(new byte[]{'H','e','l','l','o','!','\0'});
        return 1;
    }

    static void call2() {
        print();
    }

    static native int puts(byte[] str);
}
