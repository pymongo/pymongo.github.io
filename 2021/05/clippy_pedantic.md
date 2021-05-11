# [clippy开启pedantic模式](/2021/05/clippy_pedantic.md)

最近发现clippy的README中介绍了默认不开启的静态分析选项

<https://www.reddit.com/r/rust/comments/a4wblu/how_to_configure_clippy_to_be_as_annoying_as/>

clippy::cargo只是检查Cargo.toml中的license等不关键的字段，没必要开启

## clippy::nursery

clippy::nursery指的是仍在开发中的lints,可能会有误报(例如它会认为修改链表的函数会是const fn)

> cargo clippy --all -- -Wclippy::nursery

我个人最喜欢nursery的this could be a `const fn`的lint

## clippy::restriction

我的理解是clippy::restriction以前的一个clippy选项，大意是开启全部lints

但是会包含一些「已过时」的lints，例如需要显示写出return的`implicit_return`，现在Rust都改成尽量不写Return的`neddless_return`规则了

现在的lint neddless_return不建议写return<https://rust-lang.github.io/rust-clippy/master/index.html#needless_return>

而且开restriction还会警告: `blanket_clippy_restriction_lints`，大意是这个已经过时了，可能不会包含全部lints

现在最佳实践还是主用`clippy::nursery`加`clippy::pedantic`，`clippy::restriction`辅助使用即可

`clippy::pedantic`和`clippy::restriction`会有大量重复内容，所以主要用`clippy::pedantic`即可

---

开启pedantic之后突然多了一千多个警告，这些又是宝贵的学习资料

而且还能统一标准，例如0u8和0_u8是一样的表达式，但是clippy会建议你写成0_u8，这样能减少很多分歧
