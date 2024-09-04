package zskamljic.jcomp.llir;

public class UnnamedGenerator {
    private int count = 0;

    public String generateNext() {
        return "%" + count++;
    }
}
