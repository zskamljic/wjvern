public class InstanceFields {
    int i;
    float f;
    double d;

    public InstanceFields() {
        i = 1;
        f = 5;
        d = 7;
    }

    static int main() {
        var instance = new InstanceFields();
        printf(new byte[]{'%', 'd', '\n', '\0'}, instance.i);
        printf(new byte[]{'%', 'f', '\n', '\0'}, instance.f);
        printf(new byte[]{'%', 'f', '\n', '\0'}, instance.d);
        return 0;
    }

    static native int printf(byte[] str, int... params);

    static native int printf(byte[] str, float... params);

    static native int printf(byte[] str, double... params);
}
