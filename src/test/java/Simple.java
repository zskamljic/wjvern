public class Simple {
    public static void main(String[] args) {
        main();
    }

    public static int main() {
        return print();
    }

    static int print() {
        puts(new byte[]{'H','e','l','l','o','!','\0'});
        return 1;
    }

    static native int puts(byte[] str);
}
