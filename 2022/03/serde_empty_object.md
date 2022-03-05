# [解析可能为空的 json](/2022/03/serde_empty_object.md)

最近在解析 jupyter 的 parent_header 字段的时候遇到困难是如果消息不存在 parent_header 则内容为空 {}

也用不了 Option 因为 Option 表示的是 json 中没有这个字段或者是 null

最后我发现用 enum variant `EmptyObject {}` 就能完美表达这种 serde_json::Map 为空的类型

```rust
#[derive(Serialize, Deserialize, Debug)]
#[serde(untagged)]
pub enum ParentHeader {
    Header(Header),
    EmptyObject {},
}

#[test]
fn test_deserialize_parent_header() {
    serde_json::from_str::<ParentHeader>("{}").unwrap();
    serde_json::from_str::<ParentHeader>(
        r#"{
            "msg_id": "9cc6a59a-02bec7392f461261e0d24625_1803397_237",
            "msg_type": "status",
            "username": "w",
            "session": "9cc6a59a-02bec7392f461261e0d24625",
            "date": "2022-03-04T11:52:23.025471Z",
            "version": "5.3"
        }"#,
    )
    .unwrap();
}
```
