# [FutureExt::left_future()](/2023/02/expected_async_block_found_a_different_async_block.md)

两个或多个 stream, async block/fn 明明是一样的返回值但是会被编译报错类型不一致

> expected `async` block, found a different `async` block

- <https://stackoverflow.com/questions/71070434/expected-async-block-found-a-different-async-block>
- <https://users.rust-lang.org/t/what-if-some-branches-in-pattern-matching-need-to-use-asynchrony-and-some-dont/62830/2>
- <https://stackoverflow.com/questions/72651369/rust-expected-type-x-but-found-type-x>
- <https://stackoverflow.com/questions/51885745/how-do-i-conditionally-return-different-types-of-futures>

> Ok(1).map(|n| async { add(n).await }).unwrap_or_else(|_| async { 0 }).await

由于每个 async block 编译器认为生成的 generator 类型不同，业界/社区的主流用法是通过 boxed 去规避

```rust
async fn f() -> i32{
    Ok(1)
        .map(|_| async { 1 })
        .unwrap_or_else(|_| async { 0 }).await
}

/// similar to StreamExt::left_stream
async fn f1() -> i32 {
    Ok::<_, Infallible>(1)
        .map(|_| async { 1 }.left_future())
        .unwrap_or_else(|_| async { 0 }.right_future()).await
}

async fn f2() -> i32 {
    use tokio_util::either::Either;
    Ok::<_, Infallible>(1)
        .map(|_| Either::Right(async { 1 }))
        .unwrap_or_else(|_| Either::Left(async { 0 })).await
}

async fn f3() -> i32 {
    Ok::<_, Infallible>(1)
        .map(|_| async { 1 }.boxed())
        .unwrap_or_else(|_| async { 0 }.boxed()).await
}
```
