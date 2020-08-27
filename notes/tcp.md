[TCP 的那些事儿（上）](https://coolshell.cn/articles/11564.html)

了解TCP/IP的协议，运作原理以及如何TCP的调优

关于TCP协议，首先第一个要记住状态转移图，怎么建立连接/断开连接，状态怎么变迁。TCP没有连接，是靠状态维护连接的。

其次要了解TCP怎么保证可靠性，就是丢包以后怎么重传，重传有哪些技术点？

[然后重传会让你联想到拥塞控制，拥塞控制到滑动窗口......](https://coolshell.cn/articles/20977.html)

[程序员练级攻略](https://coolshell.cn/articles/4990.html)

《TCP/IP 详解 卷1:协议》

实践任务：

- 理解什么是阻塞（同步IO），非阻塞（异步IO），多路复用（select, poll, epoll）的IO技术
- 写一个网络聊天程序，有聊天服务器和多个聊天客户端（服务端用UDP对部分或所有的的聊天客户端进Multicast或Broadcast）
- 写一个简易的HTTP服务器

## TCP建立连接三次握手(three-way handshake)

TODO

## 什么是粘包

TCP协议粘包问题是因为应用层协议开发者的错误设计所导致的，他们忽略了TCP协议数据传输的核心机制——基于字节流，其本身不存在消息和数据包等概念

所有的数据传输都是Stream，需要应用层自己设计消息的边界，既Message Frame

所以粘包的主要原因是应要跟没有基于长度或终止符的消息边界，导致多个消息的粘连

例如HTTP的Content-Length就是基于长度的消息边界

另外还可以特殊规则，例如接收方可以根据收到的数据能否解析成合法的JSOn判断消息是否终结

## 丢包、重传和拥塞控制

TODO

