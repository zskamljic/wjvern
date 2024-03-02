package zskamljic.jcomp.llir;

public class Utils {
    private Utils() {
    }

    public static String escape(String name) {
        if (!name.contains("\"") && (name.contains("/") || name.contains("<"))) {
            return STR."\"\{name}\"";
        }
        return name;
    }
}
