# [blanket implementations](/2021/05/blanket_implementations.md)

翻看[ToUppercase](https://doc.rust-lang.org/std/char/struct.ToUppercase.html#blanket-implementations)
文档会发现下面有个`blanket impl`的介绍

这个 blanket impl 我认为像trait那样不翻译成中文更好

简单来说就是`impl Trait for T`，例如实现了Display的Struct都会自动实现ToString

像trait或blanket_impl这种Rust术语就不可能有信雅达的翻译，所以平时还需阅读更多英文资料
