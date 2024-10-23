package zskamljic.wjvern;

import zskamljic.wjvern.llir.IrMethodGenerator;
import zskamljic.wjvern.llir.models.LlvmType;
import zskamljic.wjvern.llir.models.Parameter;

import java.util.ArrayList;
import java.util.List;

public class StandardFunctions {
    private StandardFunctions() {
        // Prevent instantiation
    }

    public static void callThrow(IrMethodGenerator generator, LlvmType exceptionType, String... parameters) {
        generator.call(
            LlvmType.Primitive.VOID,
            "__cxa_throw",
            generateThrowParameters(exceptionType, parameters)
        ); // TODO: parameters from throw
    }

    public static void invokeThrow(IrMethodGenerator generator, LlvmType exceptionType, String next, String activeHandler, String... parameters) {
        generator.invoke(LlvmType.Primitive.VOID, "__cxa_throw", generateThrowParameters(exceptionType, parameters), next, activeHandler);
    }

    private static List<Parameter> generateThrowParameters(LlvmType exceptionType, String[] parameters) {
        var parameterList = new ArrayList<Parameter>();

        for (int i = 0; i < 3; i++) {
            var parameter = i < parameters.length ? parameters[i] : "null";
            parameterList.add(new Parameter(parameter, i == 0 ? exceptionType : LlvmType.Primitive.POINTER));
        }
        return parameterList;
    }
}
