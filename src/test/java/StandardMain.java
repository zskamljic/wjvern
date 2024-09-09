public class StandardMain {
    public static void main(String[] args) {
        for (String arg : args) {
            puts(arg.getBytes());
        }

        System.exit(args.length);
    }

    static native int puts(byte[] str);
}
