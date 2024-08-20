package zskamljic.jcomp.llir;

import java.lang.classfile.FieldModel;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.FieldRefEntry;
import java.lang.classfile.constantpool.MemberRefEntry;
import java.lang.constant.ClassDesc;
import java.lang.reflect.AccessFlag;

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

    public static String staticVariableName(FieldRefEntry field) {
        return STR."@\{escape(STR."\{field.owner().name()}_\{field.name()}")}";
    }

    public static String staticVariableName(FieldModel field) {
        return STR."@\{escape(STR."\{field.parent().orElseThrow().thisClass().name()}_\{field.fieldName()}")}";
    }

    public static boolean isVirtual(MethodModel method) {
        return !method.flags().has(AccessFlag.FINAL) &&
            !method.flags().has(AccessFlag.STATIC) &&
            !method.methodName().stringValue().endsWith(">");
    }

    public static ClassDesc unwrapType(ClassEntry entry) {
        var type = entry.asSymbol();
        while (type.isArray()) {
            type = type.componentType();
        }
        return type;
    }

    public static boolean isSupportedClass(String className) {
        return className.equals("java/lang/Object") ||
            className.equals("java/lang/String") ||
            className.equals("java/lang/Void");
    }

    public static String vtableTypeName(String className) {
        return Utils.escape(STR."\{className}_vtable_type");
    }
}
