
## linux basic overview

Linux的API是遵循POSIX标准的，自行谷歌什么叫POSIX。Linux下程序开发几大块，文件操作，这个很重要，你要知道Linux下的一个思想叫一切皆文件，可见文件读写多重要了。I/O模型，五大I/O模型，阻塞，非阻塞，复用，信号驱动和异步I/O，环环相扣丝丝相连，概念和操作都要仔细琢磨，最重要的当属复用，就是select，poll和epoll，面试笔试就问这个东西，要知道他们的适用范围和优缺点。进程和线程，包括进程和线程的概念和区别，进程和线程的建立，同步，通信，互斥等等。网络编程，就是socket编程,Linux编程，这个学不好等于啥都没学，这个估计还得了解一下TCP/IP协议，编程方面主要是那几步，申请socket，bind，listen，accept几步，要熟悉种常见的服务器模型，进程池线程池方式的，多进程方式的，复用方式的，最重要的是复用方式的，这部分可以先只写服务器，测试直接用Telnet就好了

我的一些问题去思考:

- 网卡缓冲区和socket读写
- IO模型怎么知道socket有新数据需要读取

## 通过书籍系统的学习 linux

- beginning linux programming(linux程序设计，可以快速略过gtk这类章节，主要用来入门和打下看APUE的基础)
- The Linux programming interface(man7.org文档网站的作者力作，Linux版APUE，1600多页的巨作)
- Advance programming in the Unix environment
- Linux system programming
- Unix Network Programming Interprocess Communications
- Unix Network Programming The Sockets Networking API
- TCP/IP Illustrate Volume 1-3
