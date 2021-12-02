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

## 孤儿规则

双刃剑，有好有坏，好处是保护上游代码，坏处是不能直接为上游库的实现第三方 trait不方便，参考 notes/design_pattern_or_pattern/newtype.md

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

## 引用语法的歧义

&i.to_ne_bytes() 到底是 (&i).to_ne_bytes() 还是 &(i.to_ne_bytes())

## 官方库 API 设计问题

### HashMap 遍历的顺序随机

HashMap 遍历时顺序都是随机的，原因是 Rust 故意的是一个 feature, 避免哈希冲突和黑客破解 HashMap

### futures::select! 并不是按从上到下的顺序

tokio::select! 似乎没有这个问题，或者用 futures::select_biased!

[wangrunji 的分享提到这个问题](https://github.com/madsys-dev/madsim/commit/6e6c613c5d42833629dc1d0c0e27cc9984fce9f6)

## async 传染性太强

10 个函数的调用链内，只有一行 await，结果导致所有 10 个函数都要定义成 async
