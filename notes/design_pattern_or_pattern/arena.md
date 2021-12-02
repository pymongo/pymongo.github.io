## arena
作用: 基本是存储若干指针的结构体，生命周期/内存池?，预分配内存避免内存频繁申请释放?
例子:
- `pub struct TypedArena<T>` // rustc_arena
- pub struct ResolverArenas<'a> // rustc_resolve

预分配内存对象池，所以内存对象都具有相同的生命周期

应用: rustc_arena

参考 arena in Rust 的文章

WIP...
