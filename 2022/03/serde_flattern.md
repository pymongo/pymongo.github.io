# [serde 字段继承/共用](/2022/03/serde_flattern.md)

刚学会 serde(flattern) 可以实现字段"继承"或共用的效果，
例如右图 jupyter 执行结果的 json 中，
执行成功返回 4 个字段，执行失败时会在 4 个字段的基础上额外返回例如 traceback 字段

还学了 deny_unknown_fields 可以禁止 json 出现多余字段
我挺喜欢 serde 这样超严格的 json 解析、强类型检查/反序列化


jupyter 的 json 在出错的时候都会多几个字段，通过 enum + tag + flatten 就能处理同一个 json 不同情况下字段不一致的情况

```rust
#[derive(Serialize, Deserialize, Debug)]
pub struct Reply {
    /// common fields
    pub execution_count: u32,
    pub payload: serde_json::Value,
    pub user_expressions: serde_json::Value,
    /// extra fields when error
    #[serde(flatten)]
    pub reply_status: ReplyStatus
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "snake_case")]
#[serde(tag = "status")]
pub enum ReplyStatus {
    Ok,
    Error(Error)
}

#[test]
fn test_reply_deserialize() {
    const OK_JSON: &str = r#"{
        "status": "ok",
        "execution_count": 3,
        "user_expressions": {},
        "payload": []
    }"#;
    const ERR_JSON: &str = r#"{
        "status": "error",
        "execution_count": 2,
        "user_expressions": {},
        "payload": []

        "traceback": [
          "\u001b[0;36m  Input \u001b[0;32mIn [2]\u001b[0;36m\u001b[0m\n\u001b[0;31m    print(1.eq(2))\u001b[0m\n\u001b[0m           ^\u001b[0m\n\u001b[0;31mSyntaxError\u001b[0m\u001b[0;31m:\u001b[0m invalid decimal literal\n"
        ],
        "ename": "SyntaxError",
        "evalue": "invalid decimal literal (1616495749.py, line 1)",

        "engine_info": {
          "engine_uuid": "49180d62-077c-4ce2-a9e4-54a78799fb99",
          "engine_id": -1,
          "method": "execute"
        },
    }"#;
    serde_json::from_str::<ExecuteReply>(OK_JSON).unwrap();
    serde_json::from_str::<ExecuteReply>(ERR_JSON).unwrap();
}
```
