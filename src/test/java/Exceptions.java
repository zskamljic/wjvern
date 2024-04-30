public class Exceptions {
    static int main() {
        try {
            throw new CustomException(5);
        } catch (CustomException e) {
            return e.getCode();
        } finally {
            print();
        }
    }

    static void print() {
        puts(new byte[]{'H', 'e', 'l', 'l', 'o', '!', '\0'});
    }

    static native int puts(byte[] str);
}

class CustomException extends Exception {
    private int code;

    public CustomException(int code) {
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}