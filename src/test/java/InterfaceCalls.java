public class InterfaceCalls implements Comparable<InterfaceCalls> {
    private final int value;

    public InterfaceCalls(int value) {
        this.value = value;
    }

    public static void main(String[] args) {
        var first = new InterfaceCalls(3);
        var second = new InterfaceCalls(5);

        callInterface(first, second);
    }

    static void callInterface(Comparable<InterfaceCalls> first, InterfaceCalls second) {
        if (first.compareTo(second) < 0) {
            System.exit(2);
        } else {
            System.exit(1);
        }
    }

    @Override
    public int compareTo(InterfaceCalls o) {
        return value - o.value;
    }
}
