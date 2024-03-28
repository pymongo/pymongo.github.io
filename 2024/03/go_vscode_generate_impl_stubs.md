# [Go generate interface](/2024/03/go_vscode_generate_impl_stubs.md)

Rust trait can have methods with the same name, and a struct can implement those traits with different implementations for each method. This is possible because Rust uses scoped naming for trait methods.

However, Go does not support this kind of method overloading. In Go, the method set of a type determines the interfaces it implements. Each method in a type's method set has a unique non-blank method name, and if two interfaces define a method with the same name, a type implementing that method will implement both interfaces with the same implementation

说白了就两个trait/interface有个 方法名签名 完全相同的函数，在rust中式两个不同实现的函数，而在Go中是同一个

如果interface很长很多方法，可以用一下办法像rust/java生成impl

vscode Go generate interface stubs

语法是 self(也就是Self自身的参数名) struct_name interface_name
