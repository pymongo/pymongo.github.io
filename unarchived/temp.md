
## mongodb UnitTest

```rust
#[tokio::test]
async fn test() {
    let uri = "mongodb://igb:igb@127.0.0.1:27017";
    let db = mongodb::Client::with_uri_str(&uri)
        .await
        .unwrap()
        .database("fpweb");
    update_password(
        "5fc9c2b100cf425100ace78f".to_string(),
        "$3b$12$RnqcyXPrE6DqBZ5I.4YMbuVyn.i.CbfBXRN2bbBesiFOUQSHBfWny".to_string(),
        // "vjiuhjg984792g5".to_string(),
        &db,
    )
    .await
    .unwrap();
}
```
