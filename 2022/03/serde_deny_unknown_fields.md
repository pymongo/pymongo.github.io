# [检查 json 重复/多余字段](/2022/03/serde_deny_unknown_fields.md)

纠正下我之前在群里提出的 serde 不能检查重复字段的错误观点，
指定结构体去反序列化能检查重复字段的，只是用 Value 是不检查重复字段

除了重复字段，还学了下 Rust 反序列化的 deny_unknown_fields 可以禁止 json 出现额外字段，
我挺喜欢 serde 算是将 json 解析的安全性/类型检查做到极严格了

```rust
#[derive(Deserialize, Debug)]
struct A { comment: String }

#[derive(Deserialize, Debug)]
#[serde(deny_unknown_fields)]
struct B { comment: String }

#[test]
fn a() {
    const JSON_WITH_DUP_KEY: &str = r#"
    {
        "comment": "foo",
        "comment": "bar"
    }
    "#;
    const JSON_WITH_UNUSED_FIELD: &str = r#"
    {
        "comment": "foo",
        "unused_field": "bar"
    }    
    "#;
    assert!(serde_json::from_str::<Value>(JSON_WITH_DUP_KEY).is_ok());
    assert!(serde_json::from_str::<A>(JSON_WITH_DUP_KEY).unwrap_err()
        .to_string().contains("duplicate field `comment`"));
    assert!(serde_json::from_str::<A>(JSON_WITH_UNUSED_FIELD).is_ok());
    assert!(serde_json::from_str::<B>(JSON_WITH_UNUSED_FIELD).is_err());
}
```
