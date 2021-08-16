# Rust 一些不好的设计/ Rust 语言缺陷

## 允许方法名和结构体名一样，就像 C 语言的 libc::stat 结构体和 libc::stat 函数

标准库中的示例 libc::stat, lib::sigaction

我的示例:

```rust
#[allow(dead_code, non_camel_case_types)]
struct stat {
    id: i32
}

#[allow(dead_code)]
fn stat() -> stat {
    stat {
        id: 0
    }
}
```

## 孤儿规则(new type 模式)

双刃剑吧，有好有坏，不过导致过多将别人上游的结构体包一层的模板代码，可以用 Deref trait自动解引用让这层抽象对调用者来说是透明的

这个把别人结构体包一层的写法叫 new type 模式，这种问题和设计模式在 ruby 上都是没有的

## move 判别粒度不够细

例如结构体A的字段1被move到另一个变量，再into转成结构体B，转换的过程不需要字段1,但还是会报错

## cargo alias 不够强大

感觉不如 npm 的 package.json 的 run alias 强大

## bad code example

```rust
union union<'union> {
    union: &'union union<'union>
}
```
