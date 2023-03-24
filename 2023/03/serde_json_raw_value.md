# [serde_json::RawValue](/2023/03/serde_json_raw_value.md)

有一种 json 的应用场景，当前应用读取 K8s pod json 的 metadata 字段并转发给下游应用

但应用本身并不需要解析 metadata 字段的 json

一般的解决方案都是用 `metadata: serde_json::Value` 去反序列化，但能不能不反序列仅仅存储 metadata 这段 json 当字符串存储再传递给下游呢?

## raw_value feature

<https://docs.rs/serde_json/latest/serde_json/value/struct.RawValue.html>

假设解析如下 json

```json
{
    "kind": "Pod",
    "metadata": {
        "annotations": {
            "scheduling.k8s.io/group-name": "foo"
        }
    }
}
```

RawValue 实际上是一个不解析的 json 字符串，所以 RawValue 字段只能用引用，否则报错 `the size for values of type `str` cannot be known at compilation time`

```rust
#[derive(Deserialize)]
struct Pod {
    kind: String,
    metadata: serde_json::value::RawValue,
}
```

反序列化字段是个引用，如果出现生命周期报错需要用 `#[serde(borrow)]`

```
#[serde(borrow)]
metadata: &'a serde_json::value::RawValue
```

对比下 serde_json::Value 和 RawValue 反序列化后的 dbg 打印

```
metadata: Object {
    "annotations": Object {
        "scheduling.k8s.io/group-name": String("foo"),
    },
}

metadata: RawValue(
    {
        "annotations": {
            "scheduling.k8s.io/group-name": "foo"
        }
    },
),
```

## RawValue 在 sqlx 的应用

postgres 数据库中 json 类型字段的写入其实跟字符串差不多的

`sqlx::types::Json<T>` 是一个包了个 Deserialize 的 newtype

包了一层后让可反序列化的结构体也实现了 sqlx::FromRow

这样往 pg 数据库读写 json 类型时并不需要将数据反序列化成 json 结构体直接用字符串的方式写进数据库让 pg 解析即可

但 FromRow: Sized 意味着字段不能用有引用 <https://github.com/launchbadge/sqlx/issues/1866#issuecomment-1128336620>

> sqlx::types::Json<Box<serde_json::value::RawValue>>

目前 RawValue 在 sqlx 只能读数据时用，写数据时只能用 serde_json::Value

同理，不想在结构体引入指针和生命周期，反序列化本文例子的 metadata 字段也可以用 `Box<serde_json::value::RawValue>`
