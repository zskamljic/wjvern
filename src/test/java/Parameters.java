public class Parameters {
    final int something(int a) {
        return a;
    }

    static int main() {
        var instance = new Parameters();
        return instance.something(5);
    }
}
