# JCompiler

JCompiler compiles your Java classes to native executables. Class file is first parsed using the Java Class-File
API ([JEP-484](https://openjdk.org/jeps/484), [JEP-466](https://openjdk.org/jeps/466), [JEP-457](https://openjdk.org/jeps/457)),
then transforms the code to [LLVM-IR](https://llvm.org/docs/LangRef.html), links the files, uses llvm `opt` with `-O3`
and finally compiles the result with `clang++` to produce a native executable.

## Supported features

Currently only a subset of Java is supported (tested with JDK 22, JDK 23).
The following features have been tested (but more might be available):

- Standard Java main function (also supporting `static int main()` for development reasons)
- [Linking with native functions](#linking-with-native-functions)
- OOP - functions, fields, inheritance (fields, methods, overriding), interfaces
- Conditional statements (switch expressions included)
- Basic exceptions (using trimmed version of java.lang.Exception, permits subclasses)
- Function overloading
- Arrays of primitives, objects
- Trimmed version of strings
- More basic features

For example of code that compiles and works see [here](src/test/java).

## Linking with native functions

Native functions can be linked in final executable by declaring a `static native` method, i.e:

```java
static native int puts(byte[] str); // Links to C standard library puts

static native int printf(byte[] str, int... parameters); // Same, but with printf, allowing varargs
```

Calling above methods will directly call native C functions with same parameters. Note that zero terminator is required
when interacting with C strings, similarly, strings comming from C code will contain a '\00' terminator (including the
args of main).

Additionally, other libraries can be linked (using the familiar `-l` cli parameter, but accepting relative or absolute
paths as well). If specified, linked functions can be accessed as any other native method (see sample above).

Usage in production is not recommended. No future/past compatibility guaranteed at this time.

## Memory

Currently, all memory is managed via stack, garbage collection is not present at all (nor are there any plans for it).

## Known limitations

The following functionalities are currently not supported (yet?):

- static initializers
- majority of java.lang.String methods (for full list see [here](src/main/resources/unsupported_functions.json))
- reflection
- most standard library classes

## Compatibility

As previously mentioned, code was tested using JDK 22 and JDK 23. The clang versions used in testing were `17.0.6` and
`18.1.8`. Compilation was only tested on Linux, with clang on PATH.

## License

Project uses Apache 2.0 license. More info in [license file](LICENSE).