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

## 静态链接和动态链接库

编译器除了可以生成可执行文件，还能生成动态/静态链接库

静态库在编译链接时将引用的代码和数据复制到二进制文件中，只是一种简单的拼接，静态库的缺点是浪费内存空间

但是有些情况，例如mac交叉编译linux时没有linux的libssl，可以通过静态链接crate的ssl库而非系统的ssl库解决交叉文件中动态库找不到的问题

动态库可以将链接的过程延迟到运行时执行，比如重定位发生在运行时而非编译时

Rust编译器一共支持生成 4 种库:

- 静态库: dylib, cdylib
- 动态库: rlib, staticlib

可以通过命令行参数或toml文件配置指定默认的编译产物，例如 --crate-type=bin/lib(默认是rlib) 去指定编译生成可执行文件还是库文件

staticlib在Linux/Mac上会创建成.a文件(IOS/mac)

cdylib: windows上生成dll, mac生成.dylib, Linux下生成so

## 结构体的内存对齐和内存布局

例如struct(u8, u32, u16) 为了方便CPU寄存器读取，需要将结构体的内存占据大小对齐为最大的成员所占字节u32的倍数

如果用#[repr(C)]则编译器会按C语言的内存布局去对齐结构体，最终占12个字节
