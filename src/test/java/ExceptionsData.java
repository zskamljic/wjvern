public class ExceptionsData {
    static int main() {
        nested();
        return 0;
    }

    static void nested() {
        try {
            throwing();
        } catch (CustomException e) {
            printf(new byte[]{'C', 'a', 'u', 'g', 'h', 't', ':', ' ', '%', 'd', '\n', '\0'}, e.getCode());
        }
    }

    static void throwing() throws CustomException {
        throw new CustomException(5);
    }

    static native int printf(byte[] str, int... params);
}