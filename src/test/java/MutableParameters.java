public class MutableParameters {
    public static void main(String[] args) {
        System.exit(mutateParams(args.length));
    }

    static int mutateParams(int a) {
        a++;
        return a;
    }
}
