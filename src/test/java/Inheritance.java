class Parent {
    int i;
    int call;

    void parentMethod() {
        i = 5;
    }

    void dynamic() {
        call = 3;
    }
}

public class Inheritance extends Parent {
    int j;

    void childMethod() {
        j = 2;
    }

    @Override
    void dynamic() {
        call = 5;
    }

    static int main() {
        var instance = new Inheritance();
        instance.parentMethod();
        instance.childMethod();
        instance.dynamic();

        return instance.i + instance.j + instance.call;
    }
}
