# [ws-tool压缩bug](/2023/12/ws_tool_deflate_bug.md)

最近测试coinex交易所，文档中写明 `連接時，需要配置通過Deflate 算法進行壓縮，參考標準為RFC7692`

```python
import asyncio
import websockets
import json
async def send_and_receive():
    uri = 'wss://perpetual.coinex.com/'
    async with websockets.connect(uri, compression='deflate') as ws:
        await ws.send(json.dumps({
            "id": 4,
            "method": "bbo.subscribe",
            "params": [
                "BTCUSDT"
            ]
        }))
        while True:
            message = await ws.recv()
            print(message)
asyncio.run(send_and_receive())
```

然而以下的ws代码服务端会报错直接断开tcp连接

```rust
use tracing_subscriber::util::SubscriberInitExt;
use ws_tool::{
    codec::{DeflateCodec, PMDConfig, WindowBit},
    frame::OpCode,
    http, ClientBuilder, ClientConfig,
};
fn main() {
    tracing_subscriber::fmt::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .finish()
        .try_init()
        .expect("failed to init log");
    let url = "wss://perpetual.coinex.com/";
    let uri = url.parse::<http::Uri>().unwrap();
    let host = uri.host().unwrap();
    let stream = std::net::TcpStream::connect(format!("{host}:443")).unwrap();
    stream
        .set_read_timeout(Some(std::time::Duration::from_secs(5)))
        .unwrap();
    let stream = ws_tool::connector::wrap_rustls(stream, host, Vec::new()).unwrap();

    let window_bit = WindowBit::Fourteen;
    let pmd_config = PMDConfig {
        server_no_context_takeover: ClientConfig::default().context_take_over,
        client_no_context_takeover: ClientConfig::default().context_take_over,
        server_max_window_bits: window_bit,
        client_max_window_bits: window_bit,
    };
    let mut stream = ClientBuilder::new()
        .extension(pmd_config.ext_string())
        .with_stream(uri, stream, DeflateCodec::check_fn)
        .unwrap();
    stream.send(OpCode::Text, &serde_json::to_vec(&serde_json::json!({
        "id": 4,
        "method": "bbo.subscribe",
        "params": [
            "BTCUSDT",
            "BTCUSDT"
        ]
    })).unwrap()).unwrap();
    loop {
        let (header, data) = stream.receive().unwrap();
        match &header.code {
            OpCode::Text => {
                let data = String::from_utf8(data.to_vec()).unwrap();
                tracing::info!("receive {data}");
            }
            OpCode::Close => {
                stream.send(OpCode::Close, &[]).unwrap();
                tracing::info!("receive Close");
                break;
            }
            OpCode::Ping => {
                stream.send(OpCode::Pong, &[]).unwrap();
            }
            OpCode::Pong => {}
            _ => {
                unreachable!()
            }
        }
    }
}
```

Rust生态知名的active-web,tokio-tungstenite,websocket-rs这几个没一个支持压缩的，ws-tool作者说过代码实现是参考了ws-rs，果然ws-rs也是一样的报错

> [2023-12-19T14:31:39Z ERROR ws::handler] WS Error <Io(Custom { kind: BrokenPipe, error: "None" })>

[ws-tool随后的修复patch](https://github.com/PrivateRookie/ws-tool/commit/73c6906bb87cef8f46fa98b7042fe7a9b3fe7d15)

顺便也把我之前反馈的币安windowsSize设置15会报错但14不会也解决了

<https://dev.binance.vision/t/receive-invalid-json-error-with-permessage-deflate-window-bits-set-to-15-but-when-it-set-to-9-14-get-no-error/17759>

不过okx的api有点奇怪 明明启用了deflate, 但传过来的确实rsv1==false的帧, 也就是没压缩的 (我猜测是网关转发消息中间件问题)

[ws-tool 针对 okx 的修复 patch](https://github.com/PrivateRookie/ws-tool/commit/f036f0521b63265b476549bb604c258387869f62)

## lz4

浏览器实现 deflate 和 zlib 的 deflate 实现都有些小差异... 没几个能参考的...

现在大家好像更喜欢lz4等更适合流式压缩的新格式

deflate 我自己试下来, 用的cpu有点多

## per message deflate

如果是websocket server用流式压缩, 几十个链接挺容易把cpu吃满的...
websocket deflate 一个大问题同一个消息, 发给每个连接时都要压缩一次...

WebSocket 协议中的 `permessage-deflate` 扩展确实需要对每个消息进行压缩以发送给每个连接，这在发送同一消息给大量连接时可能会造成服务器端的性能瓶颈。为了缓解这一问题，业界采取了一些策略和优化措施：

1. **预压缩消息**：如果同一条消息要发送给多个客户端，服务器可以先将消息预先压缩一次，然后将压缩后的结果发送给所有接受压缩的客户端。这样，对于每个独立的WebSocket连接，服务器就不必对同一个消息重复压缩。

   ```python
   pre_compressed_message = compress(message) # 压缩消息
   for connection in connections:
       if connection.accepts_compression:
           connection.send(pre_compressed_message) # 发送预压缩的消息
       else:
           connection.send(message) # 发送未压缩的消息
   ```

2. **使用扩展或更高效的压缩算法**：虽然 `permessage-deflate` 使用的是 `deflate` 算法，但可以考虑使用其他更高效的算法，例如 Brotli（虽然目前不是标准，可能需要自定义实现）。

3. **负载均衡**：通过负载均衡，将连接分散到不同的服务器上，可以将压缩消息的负荷分散到多个服务器，这样可以减少每个服务器上的压力。

4. **资源池**：使用资源池来管理压缩器的实例可以减少实例化压缩器的开销，因为可以复用现有的压缩器实例。

5. **消息队列和发布/订阅模式**：使用消息队列和发布/订阅模式来解耦消息的发送逻辑。服务器仅需发布一次消息，而后台服务负责将消息传递给所有订阅的连接。

6. **硬件加速**：在支持的硬件和操作系统上，可以使用硬件加速的压缩库来提高性能。

7. **限制压缩的使用**：在不是非常需要压缩的场景中，可以选择不对消息进行压缩。例如，对于小消息，压缩可能不会带来太大的好处，甚至可能会因为压缩和解压缩的开销而导致性能下降。

8. **优化消息频率和大小**：如果可能，优化应用协议，减少消息的频率和大小，这样可以减少压缩的负担。

适当选择和结合使用这些策略，可以在不牺牲客户端性能的前提下，显著减少服务器端因消息压缩带来的性能压力。此外，随着硬件和软件的进步，新的技术和方法可能会被开发出来以进一步解决这个问题。
