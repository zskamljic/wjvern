public final class ObjectArrays {
    private final int x;

    public ObjectArrays(int x) {
        this.x = x;
    }

    static int main() {
        var intArray = new int[3];

        for (int i = 0; i < intArray.length; i++) {
            intArray[i] = i;
        }

        for (int j = 0; j < intArray.length; j++) {
            print(intArray[j]);
        }

        var array = new ObjectArrays[3];
        print(array.length);

        for (int k = 0; k < array.length; k++) {
            array[k] = new ObjectArrays(k);
        }

        for (int l = 0; l < array.length; l++) {
            print(array[l].x);
        }
        return 0;
    }

    static void print(int number) {
        var pattern = new byte[]{'%', 'd', '\n', '\0'};
        printf(pattern, number);
    }

    static native int printf(byte[] str, int... params);
}
