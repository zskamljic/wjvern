public final class ForEach {
    static int main() {
        var array = new int[3];

        for (int i : array) {
            print(i);
        }

        return 0;
    }

    static void print(int number) {
        var pattern = new byte[]{'%', 'd', '\n', '\0'};
        printf(pattern, number);
    }

    static native int printf(byte[] str, int... params);
}
