# [Postgres协议解析器/client](/2020/10/pg_protocol.md)

受叶秋老师学Rust时写了一个MySQL协议解析器(client)的启发，我也想用Rust+C/C++写一个PostgreSQL的协议解析器(client)

> 对着文档写代码，主要是参考mysql internal doc实现，不过最终还是参考了mysql的代码实现。

所谓protocol，指的是数据库server和client之间的通信协议

搜索`mysql doc protocol`能找到文档`MySQL Internals Manual: Client/Server Protocol`

搜索`postgres doc protocol`能找到文档`Frontend/Backend Protocol`

知乎上有篇文章提出了研究数据库通信协议的好处:

> 为了实现高效率的RPC框架，研究了PostgreSQL数据库的通信协议。使用数据库的通信协议作为RPC协议拥有很多好处，比如无需编写客户端，且数据库的客户端还可以利用上数据库连接池带来的若干好处

## ProtocolVersion

pg的协议基于TCP/IP，目前我用的pg12/13都是3.0版本的protocol，client的initial startup-request message会包含协议版本信息，server需要支持client的协议版本才能继续通信

## pg protocol概述

类似actix-web的WebSocket API，pg server对每个client连接都会有一个类似WsSession去管理各自的负责的client

> the server launches a new “backend” child process for each client

There are a few cases (such as NOTIFY) wherein the backend will send unsolicited(未经同意的；自发的) messages, 
but for the most part this portion of a session is driven by frontend requests.

建立session后SQL命令会有两种sub-protocol: "simple query"和"extended query"(preprae statement)

## Message

All communication is through a stream of messages. 

### Message endianness(byte order)

[Reference](https://www.postgresql.org/docs/current/protocol-message-formats.html)

- 第一个字节: Message Type
- 2-5个字节: 除第一个字节(Message Type)以外剩余字节的长度

可见stream message的消息边界(message-boundary)要么通过Content-Length(HTTP, pg)，要么通过终止符

出于pg协议兼容历史版本的原因，client的initial startup-request message中没有Message Type这个字节

所以出于这个原因，除了StartupMessage以外的消息可以用一个struct去复用

### Message buffer和发送失败的原因

server和client都会将消息存入buffer中，再去解析消息，假设网络良好那么消息发送失败的可能原因是:

- MessageLength错误，使得消息不完整
- 内存不足，buffer存不下消息

如果通信中途出现消息解析错误，建议中断连接，因为恢复消息边界的可能性不大(since there is little hope of recovering message-boundary synchronization)

### pg文档中没有提及的数据类型

通信过程中所有字符串都是std::ffi::CStr/CString格式

例如: 83, 0, 0, 0, 25, 99, 108, 105, 101, 110, 116, 95, 101, 110, 99, 111, 100, 105, 110, 103, 0, 85, 84, 70, 56, 0

表示: key-value pair "client_encoding\0": "UTF8\0"

TODO Int32到底是u32还是i32

### client request StartupMessage

```
let mut startup_msg_body: Vec<u8> = Vec::new();
startup_msg_body.extend(&0x00_03_00_00.to_be_bytes());
startup_msg_body.extend(b"user\0");
startup_msg_body.extend(b"postgres\0");
// terminator of startup_msg_body, only startup_message has terminator and without first byte message type(historical reason)
startup_msg_body.push(0u8);
let body_len = startup_msg_body.len() as u32 + 4u32;
let mut startup_msg: Vec<u8> = Vec::new();
startup_msg.extend(&body_len.to_be_bytes());
startup_msg.append(&mut startup_msg_body);
```

### server response StartupMessage

```text
82, 0, 0, 0, 8, 0, 0, 0, 0 ReadyForQuery { pg_session_status: i32 }

Multi ParameterStatus { key: CStr, value: CStr }
83, 0, 0, 0, 22, 97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110, 95, 110, 97, 109, 101, 0, 0
83, 0, 0, 0, 25, 99, 108, 105, 101, 110, 116, 95, 101, 110, 99, 111, 100, 105, 110, 103, 0, 85, 84, 70, 56, 0
83, 0, 0, 0, 23, 68, 97, 116, 101, 83, 116, 121, 108, 101, 0, 73, 83, 79, 44, 32, 77, 68, 89, 0
83, 0, 0, 0, 25, 105, 110, 116, 101, 103, 101, 114, 95, 100, 97, 116, 101, 116, 105, 109, 101, 115, 0, 111, 110, 0
83, 0, 0, 0, 27, 73, 110, 116, 101, 114, 118, 97, 108, 83, 116, 121, 108, 101, 0, 112, 111, 115, 116, 103, 114, 101, 115, 0
83, 0, 0, 0, 20, 105, 115, 95, 115, 117, 112, 101, 114, 117, 115, 101, 114, 0, 111, 110, 0
83, 0, 0, 0, 25, 115, 101, 114, 118, 101, 114, 95, 101, 110, 99, 111, 100, 105, 110, 103, 0, 85, 84, 70, 56, 0
83, 0, 0, 0, 24, 115, 101, 114, 118, 101, 114, 95, 118, 101, 114, 115, 105, 111, 110, 0, 49, 50, 46, 52, 0
83, 0, 0, 0, 35, 115, 101, 115, 115, 105, 111, 110, 95, 97, 117, 116, 104, 111, 114, 105, 122, 97, 116, 105, 111, 110, 0, 112, 111, 115, 116, 103, 114, 101, 115, 0
83, 0, 0, 0, 35, 115, 116, 97, 110, 100, 97, 114, 100, 95, 99, 111, 110, 102, 111, 114, 109, 105, 110, 103, 95, 115, 116, 114, 105, 110, 103, 115, 0, 111, 110, 0
83, 0, 0, 0, 27, 84, 105, 109, 101, 90, 111, 110, 101, 0, 65, 115, 105, 97, 47, 83, 104, 97, 110, 103, 104, 97, 105, 0
Multi ParameterStatus {
    "application_name": ""
    "client_encoding": "UTF8"
    "DateStyle": "ISO, MDY"
    "integer_datetimes": "on"
    "IntervalStyle": "postgres"
    "is_superuser": "on"
    "server_encoding": "UTF8"
    "server_version": "12.4"
    "session_authorization": "postgres"
    "standard_conforming_strings": "on"
    "TimeZone": "Asia/Shanghai"
}

75, 0, 0, 0, 12, 0, 1, 82, 152, 171, 183, 94, 73 BackendKeyData { process_id: i32, secret_key: i32 }
90, 0, 0, 0, 5, 73 ReadyForQuery { pg_session_status: u8 }
```

## Extend Query

### portal: 类似cursor

使用不同的术语的原因是: use a different term since cursors don't handle non-SELECT statements

===

请求/查询的详细源码请看[我的github仓库](https://github.com/pymongo/pg_client)

通过查文档写pg client的实战，我学到了大端序和小端序(little-endian)，并得知mac/linux的操作系统默认字节序naive-endian是little-endian

同时也学到了std::ffi::CStr的读写与解析，更重要的是，我掌握了一些处理IO的通用知识

## BufReader和Cursor

先思考TcpStream与pg server通信的以下几个问题:

1. 怎么知道server发送的消息已经发完了?
2. 怎么获取kernel/网卡上TCP的buffer?
3. 为什么TcpStream里面的flush方法是空白的?
4. BufReader默认缓冲区是8k，如果超过8k会怎样?
5. 如果从缓冲区中读取到消息不完整的话，会将已读数据重新放回缓存区吗?

首先TcpSream本质上通过socket实现，socket内部又是一个libc+sys/unix/fd.rs<mark>文件描述符</mark>的实现

所以学好Linux系统对文件描述符的IO读写，就一并能理解socket和tcpstream的IO和系统调用

pg的通信中，经常遇到client发一条消息，server会连发好几条消息的情况

如何才能得知server的消息已经读完呢？

我一开始的思路是设置一个很大的buffer，读取数据时读到连续的一片0则发现消息已经读完了

如何重复利用read_buffer?而不用每次分配一段新的全0 buffer去读

> every call to read on TcpStream results in a system call

我自己实现的read并不高效，最终使用了标准库的BufReader帮我自动回收/循环利用 read_buffer以及自动得知本次读取bytes的长度

做pg_client的过程中发现pg文档的Int类型并未说明是否有符号，文档也没有example，消息类型/种类太多，经同事建议

还不如用C/C++和Rust写一个HTTP client/server 以及WebSocket client
