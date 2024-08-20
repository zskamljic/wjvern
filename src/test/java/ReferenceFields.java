public final class ReferenceFields {
    private int[] array;
    private ReferenceFields ref;

    static int main() {
        var refs = new ReferenceFields();
        refs.array = new int[]{1, 2};
        printInt(refs.array[0]);
        printInt(refs.array[1]);

        refs.ref = new ReferenceFields();
        refs.ref.array = new int[]{3, 4};
        printInt(refs.ref.array[0]);
        printInt(refs.ref.array[1]);

        return 0;
    }

    static void printInt(int i) {
        printf(new byte[]{'%', 'd', '\n', '\0'}, i);
    }

    static native int printf(byte[] str, int... params);
}
