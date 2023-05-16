# [serde alias](/2023/05/serde_alias.md)

serde alias 目前主要有两种应用场景

1. 业务字段重命名兼容老字段名字
2. 一个字段的可能有多个不同名字但类型相同

情况 2 其实用 serde enum 也能办到，

不同云产商对 K8s 的 gpu 资源命名有多种，一般叫 nvidia.com/gpu 有的也叫 tencent.com/gpu 等等

```rust
#[derive(Deserialize)]
struct A {
    #[serde(alias = "nvidia.com/gpu", alias = "tencent.com/gpu")]
    gpu: f64
}
from_str::<A>(r#"{"nvidia.com/gpu":1}"#).unwrap();
from_str::<A>(r#"{"tencent.com/gpu":1}"#).unwrap();
// Error("duplicate field gpu")
from_str::<A>(r#"{"nvidia.com/gpu":1, "tencent.com/gpu":2}"#).unwrap();
```

默认下 serde_json 允许重复字段，重复字段中后一个出现的值会覆盖前一个值

用了 alias 的字段就不允许重复了，没用 alias 的字段可用 `#[serde(deny_unknown_fields)]` 拒绝重复字段

用 enum 也能实现多个可能的名字选一个的效果，但是明显啰嗦太多了

```rust
#[derive(Deserialize)]
// #[serde(untagged)]
enum Gpu {
    #[serde(rename = "nvidia.com/gpu")]
    Nvidia(f64),
    #[serde(rename = "tencent.com/gpu")]
    Tencent(f64),
}
```
