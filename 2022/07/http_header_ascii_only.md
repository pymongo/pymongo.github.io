# [HTTP header ascii](/2022/07/http_header_ascii_only.md)

最近我的的一个应用的数据链路是这样的:

1. HTTP json -> python flask
2. convert python flask req json dict to str (json.dump)
3. python Popen and pass step.2 str as arg to binary
4. binary pass step.3 arg as header to ws server
5. ws server decode ws header

然后发现只要数据中包含中文路径 tokio-tungstenite ws 客户端这边就 panic at Utf8

原来是 HTTP Header 中只允许是 ascii 编码，解决方案就 urlencode 一下好了

## ws client 加 header

由于 ws 协议关系，客户端第一次握手的请求中 body 必须为空，所以想带简单参数放 query_string, path

想放复杂结果的 json 只能放在自定义的 Header 中

而且要带几个 secret/token 之类的 ws 协议固定需要的几个 header

好在 tungstenite 库能自动生成一个 ws 协议所需 header 的模板 hyper::Request 然后自行学习 hyper 的 API 去改 header 即可

```rust
let mut req = tokio_tungstenite::tungstenite::client::IntoClientRequest::into_client_request(url).unwrap();
req.headers_mut().insert(
    "X-AUTH",
    ascii_json_str.parse().unwrap(),
);
let (stream, _) = connect_async(req).await.unwrap();
```
