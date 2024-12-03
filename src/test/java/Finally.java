public class Finally {
    static int main() {
        new Exception();
        try {
            return 0;
        } finally {
            return 1;
        }
    }
}
