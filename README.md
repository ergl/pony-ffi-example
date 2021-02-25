
This project mirrors the code used for C FFI section of the Pony tutorial.

- [Linking to C libraries](https://tutorial.ponylang.io/c-ffi/linking-c.html) covers how to make Pony link the desired libraries using the `use "lib:XXX"` and `use "path:XXX"` statements.

- [C ABI](https://tutorial.ponylang.io/c-ffi/c-abi.html) covers how to compiler your C code to a shared library so you can use it from Pony code.

There are two ways of letting the compiler know where to find your libraries:

- Using the `use "path:XXX"` statement on your Pony files.
- Using the `--path <path>` option for the Pony compiler.

The key is to first build your C code into a shared library, and put the resulting `.so` / `.dylib` etc somewhere that you can specify via `use "path:..."` or supply to the compiler using the `--path` flag.

If you use the `--path` flag on the compiler, you don't need to specify the path to your C library from Pony code.
