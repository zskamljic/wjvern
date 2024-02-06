package zskamljic.jcomp.llir;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.lang.constant.ClassDesc;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class IrTypeMapperTest {
    @ParameterizedTest
    @CsvSource({
        "I,i32",
        "V,void"
    })
    void mapTypeReturnsCorrectForPrimitive(String input, String expected) {
        var classDesc = ClassDesc.ofDescriptor(input);

        var actual = IrTypeMapper.mapType(classDesc);

        assertTrue(actual.isPresent());
        assertEquals(expected, actual.get());
    }
}