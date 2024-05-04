package zskamljic.jcomp.llir;

import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.MemberRefEntry;

public class Utils {
    private Utils() {
    }

    public static String escape(String name) {
        if (!name.contains("\"") && (name.contains("/") || name.contains("<") || name.contains("("))) {
            return STR."\"\{name}\"";
        }
        return name;
    }

    public static String methodName(String parent, MethodModel method) {
        return escape(STR."\{parent}_\{method.methodName()}\{method.methodTypeSymbol().descriptorString()}");
    }

    public static String methodName(MemberRefEntry method) {
        return escape(STR."\{method.owner().name()}_\{method.name()}\{method.type()}");
    }
}
