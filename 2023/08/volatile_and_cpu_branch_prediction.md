# [volatile 不解决分支预测](/2023/08/volatile_and_cpu_branch_prediction.md)

之前看书碰见过 volatile 好几次一直没记笔记，最近看 程序员的自我修养 书中也提到了 volatile 所以得重视起来

根据 ptr::read_volatile 的文档: `guaranteed to not be elided or reordered by the compiler`

由于 CPU 读写速度远快于内存，所以 CPU 会分支预测某个 if 大概率走 true 分支的时候就会提前执行完 true 分支的指令

## 分支预测导致单例模式要 double check

显然 volatile 只能解决**编译器优化掉和重排** 并不能干预 CPU 分支预测提前执行

程序员的自我修养 书中说 引入 barrier 函数和 double-check 解决指令重排导致的单例初始化问题

## branch prediction side-channel attack

malware(恶意软件) 欺骗 CPU 利用分支预测提前执行的特点 提前读取其他进程的内存数据而不会 SIGSEGV

目前只能通过操作系统来防御这样分支预测的 malware
