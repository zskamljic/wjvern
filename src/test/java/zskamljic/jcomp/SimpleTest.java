package zskamljic.jcomp;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertTrue;

class SimpleTest {
    @AfterAll
    static void tearDown() throws IOException {
        //Files.deleteIfExists(Path.of("a.out"));
    }

    @Test
    void compilesSimple() {
        Main.main(new String[]{"target/test-classes/Simple.class", "-d"});

        assertTrue(Files.exists(Path.of("a.out")));
    }
}
