# [WebSocket中broker、Actor等概念](/2020/04/mq_broker_actor.md)

以前我用过两个Java的WebSocket客户端：OkHttp和java-websocket，也略微接触过js的WebSocket API，

因业务需求我需要改WebSocket的服务端，发现ws服务端还是比ws客户端难多了

无论是OkHttp还是java-websocket的ws客户端实现都很简单，无非就两步

1. impl SocketListener的onMessage、onOpen/Close等方法
2. 自己定义一个onMessage的Interface，让Activity中去定义ws来数据之后要干什么

知名的WebSocket服务端有Spring-websocket，nodejs的websocket等等

WebSocket服务端开发必须了解的几个名词的概念：

MQ: Message Queue(消息队列)

broker: 也叫Message Broker，帮你把消息从发送端传送到接收端，有点像交换机？

例如Erlang的RabbitMQ的简介如下:

> RabbitMQ is an open-source message-broker software that...

**Actor**

Actor可能来源于Java的Akka框架，影响了后来Rust的actix等等，感觉Actor的概念跟线程很像
