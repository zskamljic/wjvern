class Parent {
    int i;

    void parentMethod() {
        i = 5;
    }
}

public class Inheritance extends Parent {
    int j;

    void childMethod() {
        j = 2;
    }

    static int main() {
        var instance = new Inheritance();
        instance.parentMethod();
        instance.childMethod();

        return instance.i + instance.j;
    }
}
