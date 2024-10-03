package zskamljic.jcomp.llir;

import zskamljic.jcomp.llir.models.LlvmType;

import java.lang.classfile.ClassModel;
import java.lang.classfile.FieldModel;
import java.lang.classfile.MethodModel;
import java.lang.classfile.constantpool.ClassEntry;
import java.lang.classfile.constantpool.FieldRefEntry;
import java.lang.classfile.constantpool.MemberRefEntry;
import java.lang.classfile.constantpool.MethodRefEntry;
import java.lang.constant.ClassDesc;
import java.lang.reflect.AccessFlag;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public class Utils {
    private Utils() {
    }

    public static String escape(String name) {
        if (!name.contains("\"") && (name.contains("/") || name.contains("<") || name.contains("("))) {
            return "\"" + name + "\"";
        }
        return name;
    }

    public static String methodName(String parent, MethodModel method) {
        return escape(parent + "_" + method.methodName() + method.methodTypeSymbol().descriptorString());
    }

    public static String methodName(MemberRefEntry method) {
        String owner;
        var ownerName = method.owner().name().stringValue();
        if (ownerName.startsWith("[")) {
            owner = "java_Array";
        } else {
            owner = ownerName;
        }
        return escape(owner + "_" + method.name() + method.type());
    }

    public static String staticVariableName(FieldRefEntry field) {
        return "@" + escape(field.owner().name() + "_" + field.name());
    }

    public static String staticVariableName(FieldModel field) {
        return "@" + escape(field.parent().orElseThrow().thisClass().name() + "_" + field.fieldName());
    }

    public static boolean isVirtual(MethodModel method) {
        return !method.flags().has(AccessFlag.FINAL) &&
            !method.flags().has(AccessFlag.STATIC) &&
            !method.methodName().stringValue().endsWith(">");
    }

    public static boolean isNative(MethodModel method) {
        return method.flags().has(AccessFlag.NATIVE);
    }

    public static ClassDesc unwrapType(ClassEntry entry) {
        var type = entry.asSymbol();
        while (type.isArray()) {
            type = type.componentType();
        }
        return type;
    }

    public static String vtableTypeName(String className) {
        return Utils.escape(className + "_vtable_type");
    }

    public static String methodDeclaration(MethodRefEntry method, boolean isStatic) {
        var type = IrTypeMapper.mapType(method.typeSymbol().returnType());
        List<String> parameters = method.typeSymbol()
            .parameterList()
            .stream()
            .map(IrTypeMapper::mapType)
            .map(Objects::toString)
            .collect(Collectors.toCollection(ArrayList::new));
        if (!isStatic) {
            parameters.addFirst(new LlvmType.Pointer(IrTypeMapper.mapType(method.owner().asSymbol())).toString());
        }

        var parameterString = String.join(", ", parameters);

        var name = Utils.methodName(method);
        return "declare " + type + " @" + name + "(" + parameterString + ")";
    }

    public static String methodDeclaration(String owner, MethodModel method) {
        var type = IrTypeMapper.mapType(method.methodTypeSymbol().returnType());
        List<String> parameters = method.methodTypeSymbol()
            .parameterList()
            .stream()
            .map(IrTypeMapper::mapType)
            .map(Objects::toString)
            .collect(Collectors.toCollection(ArrayList::new));
        if (!method.flags().has(AccessFlag.STATIC)) {
            parameters.addFirst(new LlvmType.Pointer(new LlvmType.Declared(Utils.escape(owner))).toString());
        }

        var parameterString = String.join(", ", parameters);

        var name = Utils.methodName(owner, method);
        return "declare " + type + " @" + name + "(" + parameterString + ")";
    }

    public static boolean isValidSuperclass(ClassModel current, ClassModel parent) {
        return !(current.flags().has(AccessFlag.INTERFACE) && !parent.flags().has(AccessFlag.INTERFACE));
    }
}
