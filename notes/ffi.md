# FFI编程

## 使用Rust为其它语言开发库的两种方法

例如字节跳动的飞书通过Rust编写Mac/Win/IOS/Android四个平台的客户端的聊天库

包含WebSocket/SQLite等复杂功能

绝大部分都是利用C ABI(Application Binary Interface)进行调用

很少使用wasm进行跨语言调用

## FFI的困难之处

host(主动调用方，例如Java/Android)

如果host带GC机制而guest不带，则资源的创建和释放上会带来写问题

复杂的类/结构体在两种语言间映射很可能会失真或不准确

如果两边的语言都是运行在VM之上，非常困难甚至不可能实现FFI

所以要想FFI，两边语言至少有一边是没有GC且非VM语言

那么最后就只剩Rust/C/C++可以作为guest语言了，至少目前来看Go想要编程成安卓的库还非常困难，至少FFI到native原生环境难，Go FFI到Flutter环境容易点

## Rust FFI编程关键字

### raw identifier

如果C语言的函数是Rust的关键字怎么办？例如有个match函数可以定义成`r#match`

### no_mangle

禁用编译时混淆函数名，防止host语言想调用是找不到相应的函数名

### extern

允许外部调用Rust的函数

extern "C"，指定使用 C-ABI

extern "system"，通常类似extern "C"，但在 Win32 平台上，它是"stdcall"，或用于链接到 Windows API

### link和link_name

我没用过，不太清楚，[参考教程](https://mp.weixin.qq.com/s?__biz=MzI1MjAzNDI1MA==&mid=2648210927&idx=1&sn=ccbb529d4fa01d9b2e864e5c41dd9c72&chksm=f1c5304ac6b2b95cb54739c9966de38537197088ec79767707ecb83c871931598c45fda5969f&scene=158#rd)

## UNIX环境高级编程

如果不了解Unix环境系统编程的基础知识的话，FFI编程会看的云里雾里的

### inline函数

FFI编程相关，C语言宏在 Rust 中会实现为 #\[inline] 函数
