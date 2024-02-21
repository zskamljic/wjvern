package zskamljic.jcomp.llir;

public class UnnamedGenerator {
    private int count = 1;

    public String generateNext() {
        return STR."%\{count++}";
    }

    public String getCurrent() {
        return STR."%\{count - 1}";
    }

    public void skipAnonymousBlock() {
        count--;
    }
}
