# [LSP](/2022/08/lsp.md)

## transport

通信方式一般是父子进程管道(较少情况用 socket)，IDE 作为父进程启动 lsp server 通过管道进行父子进程双向通信

通信消息类似 HTTP 先传 header 后传 body(json), 通过 header 的 content-length 来分割消息/确定消息边界

所以在 rust-lang/rls 源码 rls/src/server/io.rs 的 `fn read_message` 中

会先 BufReader::lines 逐个读出 header 并找到 header 跟 body 之间的空行分割，

最后通过从 header 中获取到的 json 消息长度调用 read_exact 一次读完 body(json)

通过 content-length 进行消息分割读 json 显然比 serde_json::de::from_reader 通过花括号去匹配分割消息性能上会好很多

## LSP json 消息分类

LSP 消息 json 的详细结构及序列化可以看微软或者 rust-analyzer 源码 lsp-server 模块的 `struct Message` 定义

- Request: 大部分是客户端请求，少部分是服务端向客户端请求(例如 CodeLensRefresh)
- Response: 一发一回一个 req 就一定有一个 rsp
- Notification: 例如客户端编辑了某个文件给服务端通知下

## LSP 消息核心概念

### RequestId

由于客户端服务端只有一个 Stdio/pipe 作为信道，如果客户端一次发多条 Request 消息，

通过 RequestId 机制才能知道当前服务端返回的 json 是哪个请求 Id 对应的 Response

这样服务端因不同请求处理时间对多条请求返回的顺序是乱序时，客户端也能清楚知道那个响应消息对应了哪个请求消息

因此类似 TCP 的 ack 双方必须保证每个请求的 RequestId 都不一样

### ProgressToken

一些耗时很长的查询操作例如 find all reference 可以选择流式传输【一发多回】

这时候可以在请求参数加上 progress_token 让服务端找到一个 reference 就返回一个

### request cancel

LSP 的每个请求都能被 cancel, 由于 Rust 的 async cancel 基本很难用

加上 LSP 本身吃 CPU 不吃 IO 所以 rust-analyzer 和 rust-lang/rls 都没有用异步操作

---

## LSP 建立连接的时序图

跟 TCP 建立连接的三次握手过程类似

1. client->server: InitializeRequest
2. server->client: InitializeResponse
3. client->server: InitializedNotification

## LSP 关闭连接的时序图

跟 TCP 关闭连接的四次挥手过程相似

server/client 收到 Shutdown 后就会拒绝后续的任何请求了

1. client->server: ShutdownRequest
2. server->client: ShutdownResponse (rust-analyzer server 不会发这条消息)
3. client->server: ExitNotification
