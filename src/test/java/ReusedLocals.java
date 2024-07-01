public class ReusedLocals {
    private final int x;

    public ReusedLocals(int x) {
        this.x = x;
    }

    static int main() {
        var intArray = new int[3];

        for (int i = 0; i < intArray.length; i++) {
            intArray[i] = i;
        }

        var array = new ReusedLocals[3];

        for (int i = 0; i < array.length; i++) {
            array[i] = new ReusedLocals(i);
        }

        for (int i = 0; i < array.length; i++) {
            print(array[i].x);
        }
        return 0;
    }

    static void print(int number) {
        var pattern = new byte[]{'%', 'd', '\n', '\0'};
        printf(pattern, number);
    }

    static native int printf(byte[] str, int... params);
}
