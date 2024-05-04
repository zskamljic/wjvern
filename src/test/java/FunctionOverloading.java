public final class FunctionOverloading {
    int doSomething() {
        return 1;
    }

    int doSomething(int a) {
        return a;
    }

    static int main() {
        var instance = new FunctionOverloading();
        return instance.doSomething() + instance.doSomething(2);
    }
}
