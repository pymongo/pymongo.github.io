# 汇编语言

## 段地址和偏移地址

## LEA命令

(load effective address)LEA destination, source

简单的说，lea指令可以用来将一个内存地址直接赋给目的操作数，「lea不会deref，而mov会」

例如：lea eax,[ebx+8]就是将ebx+8这个值直接赋给eax，而不是把ebx+8处的内存地址里的数据赋给eax

而mov指令则恰恰相反，例如：mov eax,[ebx+8]则是把内存地址为ebx+8处的数据赋给eax

## ESP栈指针寄存器
