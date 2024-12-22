public class TryWithResources implements AutoCloseable {
    public static void main(String[] args) {
        try (var instance = new TryWithResources()) {
            instance.printWork();
        }
    }

    private void printWork() {
        puts(new byte[]{'W', 'o', 'r', 'k', '\0'});
    }

    static void printClose() {
        puts(new byte[]{'C', 'l', 'o', 's', 'e', '\0'});
    }

    static native int puts(byte[] str);

    @Override
    public void close() {
        printClose();
    }
}
