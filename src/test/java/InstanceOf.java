public class InstanceOf {
    private final int number;

    public InstanceOf(int number) {
        this.number = number;
    }

    public static void main(String[] args) {
        Object object = new InstanceOf(5);
        if (object instanceof InstanceOf iof) {
            System.exit(iof.number);
        }
    }
}
