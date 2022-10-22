# [when ser json fail](/2022/10/when_serde_json_ser_error.md)

想起之前在 rust 日报看过一个文章推荐，serde_json 什么时候 panic

项目中的用法经常是 serde_json::to_string().unwrap()

文章就举了一个例子，当 HashMap 的 key 不是 string 的时候 json::to_string 会 panic

```rust
#[test]
fn test_ser_fail() {
    let mut map = std::collections::HashMap::new();
    map.insert(vec![1], 1);
    serde_json::to_string(&map).unwrap();
}
```

> `Result::unwrap()` on an `Err` value: Error("key must be a string", line: 0, column: 0)'

文中并以此例子警示，即便 Rust 在编译时能检查出很多报错，但是有些错误无法检查出

reference: <https://www.greyblake.com/blog/when-serde-json-to-string-fails/>
