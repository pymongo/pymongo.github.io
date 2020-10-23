# epoll

Use a thread that continually checks whether socket is readable(then call wake) is quite inefficient

所以Rust异步编程中对fd(文件描述符)的IO操作要用操作系统相应的async IO events

例如 epoll(Linux)/kqueue(BSD,mac,IOS)/IOCP(windows)