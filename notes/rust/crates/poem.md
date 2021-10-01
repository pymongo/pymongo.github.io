web 框架

目前错误处理有问题，例如 AddrParseError 不会立即报错

发 SIGTERM 不能 graceful_shutdown

等 systemd TIMEOUT 了 发 kill 才打出 panic 报错

`#[oai(extract = true)` 和 `#[oai(extract)` 一样是解析成 bool

[struct APIOperationParam](https://github.com/poem-web/poem/blob/0b697a31cc41194088dc61caf6443579d399d6cc/poem-openapi-derive/src/api.rs#L79)

```rust
#[OpenApi]
impl AuthApi {
    /// API doc
    #[oai(path = "/login", method = "get")]
    async fn login(&self, #[oai(extract = true)] state: &StateExtractor) -> PlainText<&'static str> {
        PlainText("hello!")
    }
}
```

# poem_openapi 过程宏的数据模型

看 `#[derive(FromMeta)]` derive darling::FromMeta 的就是过程宏的入参模型

## struct APIOperationParam

`#[oai]` 宏修饰 `#[OpenAPi] impl` 里面的 handler 函数的 **入参**， 例如 `#[oai(extract)] state: &StateExtractor`

> #[OpenApi] impl Api { async fn(arg) }

APIOperationParam 过程宏重要参数: extract, in(表示请求参数在 query_string 还是 body 传递)

## struct APIOperation

`#[oai]` 宏(复用宏名字但功能不同)修饰 `#[OpenAPi] impl` 里面的 handler 函数(函数名)

稍微关注下这个修饰函数的宏的 tag 入参(可以搜 `tag = "` 看看 example 中的用法)，用于显示到 swagger_ui 上的函数分组

## struct APIArgs/pub fn OpenApi

`#[OpenAPi]` 宏修饰 `impl Api` 那个结构体

```rust
#[proc_macro_attribute]
#[allow(non_snake_case)]
pub fn OpenApi(args: TokenStream, input: TokenStream) -> TokenStream {
    let args = parse_macro_input!(args as AttributeArgs);
    let item_impl = parse_macro_input!(input as ItemImpl);
    match api::generate(args, item_impl) {
        Ok(stream) => stream.into(),
        Err(err) => err.write_errors().into(),
    }
}
```

