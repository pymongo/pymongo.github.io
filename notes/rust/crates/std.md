## non_exhaustive/clippy::manual_non_exhaustive

例如库代码中想要对外暴露一个 VERSION 是通过 build.rs 传递给 rustc 环境变量来构造的

我希望调用方只能用我提供的着一个常量，不得自己自行构造结构体

在 hyper 或 http 的代码中常常见到某个结构体有个 _priv: () 字段

```rust
#[derive(serde::Serialize)]
pub struct Version {
    pub version: &'static str,
    pub target: &'static str,
    /// _priv prevent pub type to construct
    /// https://github.com/hyperium/hyper/blob/0a4b56acb82ef41a3336f482b240c67c784c434f/src/client/connect/dns.rs#L47
    #[serde(skip_serializing)]
    _priv: (),
}

pub const VERSION: Version = { ... };
```

但是这种 _priv "设计模式" 已经是**过时**了， 1.40 后大伙都用 non_exhaustive

对结构体而言， non_exhaustive 表示不能用 struct expression 进行构造

对于枚举而言， non_exhaustive 表示提醒下以后可能会加新的 variant 所以 match 的时候必须加上 _ 分支/pattern (没啥用，以后 enum 加了新的 variant 编译器都能检查到哪一个 match 没同步改动)

## std::hint::unreachable_unchecked

和 unreachable! 的区别:
- 触发时可能发生 UB 而不是 panic
- 会有更多的编译器优化，unreachable! 没优化
