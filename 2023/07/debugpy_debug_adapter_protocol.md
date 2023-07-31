# [DAP 调试协议](/2023/07/debugpy_debug_adapter_protocol.md)

pycharm/spider/vscode/colab 的 variable explorer 我的理解是 python 进程专门开一个 debugger server 线程去交互

- server: `debugpy.connect(('localhost', 3344)); debugpy.wait_for_client()`
- client: `debugpy.connect(('localhost', 3344)); debugpy.wait_for_attach()`

可惜 client 执行的时候报错 <https://github.com/microsoft/debugpy/discussions/1188>

于是我试试用 Rust 写一个 client 发现原来 vscode 这堆 debugger 都用的微软的 Debug Adapter Protocol 协议

传输过程其实跟微软的 Language Server Protocol 差不多

```rust
use debug_adapter_protocol::ProtocolMessage;
use debug_adapter_protocol::requests::VariablesRequestArguments;
use debug_adapter_protocol::requests::InitializeRequestArguments;
fn main() {
    let mut stream = std::net::TcpStream::connect(std::net::SocketAddrV4::new(
        std::net::Ipv4Addr::new(127, 0, 0, 1), 3344,
    )).unwrap();
    let mut output = stream.try_clone().unwrap();
    let mut req_seq = 1;
    let req = ProtocolMessage::new(req_seq, InitializeRequestArguments::builder().adapter_id("debugpy".to_string()).build());
    write_msg_text(&mut output, &serde_json::to_string(&req).unwrap()).unwrap();
    req_seq += 1;
    let mut input = std::io::BufReader::new(stream.try_clone().unwrap());
    for _ in 0..3 {
        let msg = read_msg_text(&mut input).unwrap().unwrap();
        println!("{msg}");
    }

    let req = ProtocolMessage::new(req_seq, VariablesRequestArguments::builder().variables_reference(0).start(0).count(5).build());
    write_msg_text(&mut output, &serde_json::to_string(&req).unwrap()).unwrap();
    for _ in 0..1 {
        let msg = read_msg_text(&mut input).unwrap().unwrap();
        println!("{msg}");
    }
}
```

正是由于 DAP 和 LSP 协议差不多我直接照抄 rust-analyzer 的 lsp-server 的 read_msg_text/write_msg_text 就能读写消息

debugpy dap server 返回的消息如下，好吧似乎 variables 命令报错了也不支持

```
{"seq": 1, "type": "event", "event": "output", "body": {"category": "telemetry", "output": "ptvsd", "data": {"packageVersion": "1.6.7"}}}
{"seq": 2, "type": "event", "event": "output", "body": {"category": "telemetry", "output": "debugpy", "data": {"packageVersion": "1.6.7"}}}
{"seq": 3, "type": "response", "request_seq": 1, "success": true, "command": "initialize", "body"...}
{"seq": 4, "type": "response", "request_seq": 2, "success": false, "command": "variables", "message": "Server is not available"}
```
