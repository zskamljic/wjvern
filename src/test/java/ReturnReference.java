public final class ReturnReference {
    int returnValue() {
        return 4;
    }

    static ReturnReference createInstance() {
        return new ReturnReference();
    }

    static int main() {
        var instance = createInstance();
        return instance.returnValue();
    }
}
