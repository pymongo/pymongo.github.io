# [websocket心跳包与断线重连](/2020/04/websocket_heartbeat.md)

为了实现客服端WebSocket(以下简称ws)的断线重连机制，

我主要看了Actix、java-websocket、faye-websocket-ruby的ws服务端代码，

本文以心跳包为切入点，探索ws一些机制，构思如何通过心跳包实现断线重连

## ws的消息类型

```rust
// WebSocket message handler
match msg {
  ws::Message::Ping(msg) => ctx.pong(&msg),
  ws::Message::Pong(_) => println!("pong message"),
  ws::Message::Text(text) => ctx.text(format!("text message: {}", text)),
  ws::Message::Binary(_) => println!("binary message"),
  ws::Message::Close(_) => ctx.stop(),
  ws::Message::Continuation(_) => ctx.stop();
  ws::Message::Nop => (),
}
```

常用的消息类型是Text和Binary，不过本文主要讨论的是Ping和Pong消息类型，详见[RFC6455](https://tools.ietf.org/html/rfc6455#section-5.5.2)

## js的ws心跳包

[Web端js的ws代码Example](https://github.com/actix/examples/blob/master/websocket-chat-broker/static/index.html)

根据[MDN](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
WebSocket的文档，js的ws的API少的可怜，就用open、close、message就够了

如果使用Firefox或Charles，能看到js的ws每隔5秒就向服务器发送ping消息，内置了心跳包的功能

根据[w3.org](https://www.w3.org/TR/websockets/#ping-and-pong-frames)
的文档

> The WebSocket protocol specification defines Ping and Pong frames that can be used for keep-alive, heart-beats, network status probing, latency instrumentation, and so forth. These are not currently exposed in the API.

确实承认了js的ws确实在隐式地发ping包，不过ping和pong的API`are not currently exposed in the API`

## java-websocket

根据官方wiki文档[Java-WebSocket/wiki/Lost-connection-detection](https://github.com/TooTallNate/Java-WebSocket/wiki/Lost-connection-detection)

`setConnectionLostTimeout`设置客户端发送ping的频率以及服务端收不到ping关闭会话的TIMEOUT

实现**断线重连**的方法是：服务端监测心跳包的TIMEOUT > 客户端发送心跳包的间隔

## faye-websocket-ruby

faye-websocket-ruby不支持pong消息类型，也就是客户端发来ping无法回pong

```ruby
class MyWebsocket
  attr_reader :ws 

  def initialize env 
    @ws = Faye::WebSocket.new(env, nil, {
      :ping => 5
    })  

    @ws.on :message do |event|
      on_message(event.data)
    end 

    @ws.on :close do |event|
      @ws = nil 
    end 
  end
end
```

不过心跳包还有一个机制，服务端发ping客户端回pong也能用于保持连接

ruby这个ws库不能发pong，好在能设置建立连接后每隔5秒给客户端发一个ping

所以客户端是java-websocket，服务端是ruby时是靠服务端不断地给客户端ping来保持连接

## rust的WebSocket

actix并不是Rust语言star数最多的web框架，actixstar数排第二的话，rocket.rs(9.4k)就是第一了

不过Rust实现ws的库本来就稀少，actix作为同时支持ws和http的服务器似乎是唯一选择了

actix官方example提供了两种保持连接的方式

一种是类似java-websocket，设置心跳包的TIMEOUT

另一种是智能检测已掉线的连接(TODO 这部分的源码我还没看懂)
