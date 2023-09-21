# [链接装载库读书笔记](/2023/08/link_load_and_lib_notes.md)

## /usr/include/elf.h
size/readelf 命令都能查看 elf 文件每个 section 的长度

### elf magic

> xxd -p -l 4 a.out

读取 a.out 前 6 byte 结果是 7f454c460201 其中 7f 是 ASCII DEL, 45 4c 46 分别是 e l f 的 ASCII 编码

第五个 byte 02 表示 64bit 如果是 01 则表示 32bit，第六个 byte 01 表示 little-endian

elf indent 的 magic 部分后 7-16 byte 基本都是没啥用的保留字段了，给一些定制化的 elf 扩展格式预留

操作系统是如何区分 ELF 文件是什么类型的

```c
#define ET_REL		1		/* Relocatable file */
#define ET_EXEC		2		/* Executable file */
#define ET_DYN		3		/* Shared object file */
#define ET_CORE		4		/* Core file */
```

还有大致看看 ELF 64bit 结构体定义就能更好理解 readelf 输出结果了 

```c
typedef struct
{
  unsigned char	e_ident[EI_NIDENT];	/* Magic number and other info */
  // 重要，例如 ET_EXEC
  Elf64_Half	e_type;			/* Object file type */
  Elf64_Half	e_machine;		/* Architecture */
  Elf64_Word	e_version;		/* Object file version */
  Elf64_Addr	e_entry;		/* Entry point virtual address */
  Elf64_Off	e_phoff;		/* Program header table file offset */
  // 重要 e_sh 前缀的字段都是段表(section table)相关
  Elf64_Off	e_shoff;		/* Section header table file offset */
  Elf64_Word	e_flags;		/* Processor-specific flags */
  Elf64_Half	e_ehsize;		/* ELF header size in bytes */
  Elf64_Half	e_phentsize;		/* Program header table entry size */
  Elf64_Half	e_phnum;		/* Program header table entry count */
  Elf64_Half	e_shentsize;		/* Section header table entry size */
  // section 数组长度及指针位置信息，数组类型是 Elf64_Shdr 结构体
  Elf64_Half	e_shnum;		/* Section header table entry count */
  Elf64_Half	e_shstrndx;		/* Section header string table index */
} Elf64_Ehdr;
```

### 字符串表
section 中字符串表是这样存储的 \0foo\0bar\0

所以用下标/偏移 0 可以索引到空字符串

### .symtab Elf64_Sym

### c++filt
输入 C++ mangle/decorate 的符号名，输出还原出原始的 C++ 函数名，例如从 ELF 符号表中还原一个混淆后的 C++ 函数重载函数名

### #[link_section]
C 语言用 __attribute__((section("foo")))

### C/Rust attribute 对照表

|C|Rust|
|---|---|
|`__attribute__((__alias__("foo")))`|#[link_name = "foo"]|
|`__attribute__((section(".bss")))`|#[link_section = ".bss"]|
|`__attribute__((weak))`|#[link(weak)]|
|`__attribute__((packed))`|#[repr(packed)]|
|`__attribute__((aligned(32)))`|#[repr(align(32))]|
|`__attribute__((always_inline))`|#[inline(always)]|
|`__attribute__((naked))`|#[naked]|
|`__attribute__ ((warn_unused_result))`|#[unused_must_use]|
|C++: extern "C"|#[no_mangle]|
|__thread|#[thread_local]|
|gcc -nostdlib|#![no_std]|
|gcc -nostartfiles|#![no_main]|

<!-- |`__attribute__((constructor))`|| -->

注意 `__attribute__((section(".bss")))` 在 visual studio 工具链上可用 `#pragma data_set(".bss")`

注意 `extern "C"` 是 C++ 专有语法，因此用的时候经常套上 `#ifdef __cplusplus`

~~链接的时候如果有多个 weak symbol 则会选择占用空间最大的一个~~ 书中这个说法跟 gpt 不一致，gpt 说选择 ld 入参文件顺序的第一个 week symbol

看书/代码看到 link_section link(weak) 这些 ABI 相关的属性宏
整理了下发现都能找到 C 语言一一对应的 __attribute__

`#[naked]` 指的是让编译器别按照函数调用约定在函数调用前后注入保存恢复寄存器值的汇编指令

参考 绿色线程有栈协程的实现 <https://github.com/chyyuu/example-coroutine-and-thread/tree/stackful-coroutine-x86>

### weak/weak_ref
weak 还有一个用法是判断编译时有没有加上 -lpthread 从而让业务代码走单线程分支还是多线程分支

如果没有加 -lpthread 则 weak symbol 指针为 0 以此判断是否 -lpthread

### VMA/LMA

objdump 返回的表头中 Virtual/Load memory address 应该相等，但在嵌入式尤其是 ROM 中程序就不相等

### .init/.fini

放 C++ 全局构造和析构函数，.init 会在 main 函数之前执行，.fini 会在之后执行

(libc 大约上千个 .o) ar -t /usr/lib/x86_64-linux-gnu/libc.a

找 printf 在哪个 .o 

> objdump -t /usr/lib/x86_64-linux-gnu/libc.a | grep -w printf

### bfd.h
binary format descriptor lib

bfs_target_list() 就类似 rustup target list 列出所有 GNU 编译器后端支持的 target ABI

### ASLR(随机化布局)

代码中打印出的指针地址是 linker BASE_ADDRESS 的偏移地址，除了嵌入式和 bare-metal 应用基本不会用非 Position-independent executables

address space layout randomization 操作系统会随机分配虚拟地址空间的基地址，这是为了增加安全性，防止 malware 用绝对地址攻击

## int 0x80 系统调用

x86 `int $0x80` 等同于 RISC-V 的 ecall 二者都是系统调用

int 0x80 的系统调用 id 入参存放在 eax, 系统调用三个参数存放在寄存器 ebx,ecx,edx，返回值存放在 eax

ecall 的系统调用 id 入参存放在 x17/a7, 系统调用三个参数存放在寄存器 x10(a0),x11(a1),x12(a2), 返回值存放在 x10(a0)

x86_64 正常情况下前四个入参寄存器: rdi,rsi,rdx,rcx 返回值是 rax

## segment/section

装载时 segment=多个相同读写权限的 section 合并后的页

readelf -l 可以看 elf 文件 load 到进程地址空间后会有几个 segment

## /proc/self/maps 进程地址空间

第二列权限列的 p 表示 private 且 copy on write, s 表示 share，例如 /dev/nvidiactl 会是一个 share 段表示与其他进程一起读写该段

第四列表示主设备号和从设备号，主编号和次编号一起，决定了一个驱动设备

### 主次设备号都为零则是**匿名 VMA**
例如 heap,stack 都是主次设备号为零

### vdso/vvar 加速只读系统调用
一种特殊的内核映射，它允许用户空间程序直接访问一些内核提供的功能，而无需通过系统调用的方式。它是一种优化机制，旨在提高一些常见系统调用的性能

同理 /proc/self/maps 中的 vvar 和 vsyscall 都是跟 vdso 一样的功能，vsyscall 是为了兼容旧版本基本上不用

vvar 是所有进程都共用的一份操作系统的只读系统调用变量的页表，例如存放了时间戳

#### 进程用 time 系统调用获取时间戳的时候，是经 vdso 直接从 vvar 页表中读取时间戳的变量数值吗

```
对于Linux操作系统，在用户空间使用time系统调用获取时间戳时，并不是直接从vvar页面中读取时间戳的变量值。VDSO（Virtual Dynamic Shared Object）是一个特殊的共享库，它包含一些内核提供的函数和变量，可以在用户空间直接调用，避免了进入内核态的开销。
在x86架构下，VDSO中的时钟函数（例如gettimeofday）会通过调用一些特殊的指令（例如vdso_call）来获取时间戳。这些指令会触发一个特殊的陷阱，将控制权转移到内核态。内核会使用真正的硬件时钟或其他机制（如TSC或HPET）来获取准确的时间戳，然后返回给VDSO。VDSO将时间戳传递给用户空间的进程。

vvar（Virtual Variable）页是在用户空间映射的一个特殊页，其中包含一些与进程相关的变量，例如时间戳、进程ID等。vvar页通常由内核负责更新，以保持其值的最新状态。但是，当进程使用time系统调用获取时间戳时，通常不会直接从vvar页中读取变量值，而是通过VDSO来获取时间戳。
内核提供了一些系统调用（如gettimeofday、clock_gettime等），可以使用户空间的进程通过合适的接口来获取vvar页中的变量值。这些系统调用会在内部访问vvar页，并将所需的信息返回给用户空间的进程
```

所以说获取时间戳性能，vdso 可以优化到直接读 vvar page 变量，想起 [非凸自研的高速时间戳中间件](https://github.com/nonconvextech/fttime) [小丑一样的行为](https://rustcc.cn/article?id=43557979-ce71-420b-a228-4220c36d3823) 开一个进程 busy-wait 不断自增写时间戳到共享内存，然后其他应用读取共享内存时间戳，这样典型的就是负优化，操作系统的 vdso 时间戳获取已经是读内存级别非常快了，何必再拉一个进程跑满 CPU 一个核心去自增时间戳。不过非凸还是有牛人指正这个错误，删帖删代码库了

x86 的 rdtsc 指令和 riscv 的 rdtime 指令可以获取 uptime ，结合主板上的时钟模块有电池的会记录准确 UTC 时间，当主板电池断电很久后，操作系统下次开机也能从网络或者用户设定时间将 UTC 时间纠正到时钟模块上

### heap VMA 没有可执行权限
~~书上代码说 heap 段有可执行权限是错误的~~ 毕竟是二十年前的书 Linux 1.0-2.0 版本堆内存有可执行权限
我验证了下 /proc/self/maps 除了 elf 文件和动态库的 .text 段，还有 vdso 段有可执行权限，堆内存就没有可执行权限。

于是我好奇堆内存没有可执行权限那要怎样才能像JIT那样【动态执行未知代码】，gpt 说用 mmap 分配一段有可执行权限的内存就行了

<https://twitter.com/ospopen/status/1691360826220019712>

其实 dlopen 运行时打开动态库也算有点动态可执行内存的感觉

### JIT 的一种实现——栈机

```
栈机（Stack machine）是一种计算机体系结构，其指令集架构操作栈作为主要的数据结构。在栈机中，计算机指令直接对栈进行操作，而不是像传统的计算机体系结构中那样通过寄存器与内存进行数据传输。

栈机的基本思想是使用栈来存储和操作数据。栈是一种后进先出（Last-In-First-Out，LIFO）的数据结构，即最后压入栈的数据最先弹出。栈机的指令集包括一系列针对栈进行操作的指令，例如将数据压入栈、将数据弹出栈、对栈顶数据进行运算等。

相较于传统的寄存器或内存机器，栈机具有一些优势和特点。首先，栈机的指令数量通常较少，指令长度也较短，简化了指令的编码和解码过程。其次，栈机操作的数据都在栈顶，减少了指令操作数的寻址和加载过程，提高了指令的执行效率。此外，栈机还具有天然的函数调用和递归处理能力。

栈机在实际应用中有一定的局限性，例如，由于频繁的栈操作可能导致内存访问的效率降低。因此，栈机通常在特定的领域或特定的应用中使用，如虚拟机、编程语言解释器、函数式编程语言等。
```

### mmap 绑定 /dev/zero 匿名设备
如果只是想划分一段内存不想着关联到文件上，可以给 mmap 的 fd 传入 -1 再加上 MAP_ANONYMOUS flag 就会通过 /dev/zero 映射到纯内存中

### 为什么 .text 段不在 0x08048000

一个原因是 ASLR 操作系统随机化基地址，另一个原因是 linux 源码 fs/Binfmt_elf.c load_elf_interp 和 elf_map, do_brk 函数做了很取巧的设计将 .bss 段运行时放进堆中

getconf PAGE_SIZE 返回 4096 页大小，十六进制是 0x1000 所以第一个页的范围理论是在 0x08048000~0x08049000

### 页合并(Page Coalescing)
如果多个不同权限的段大小远小于 4096，各自分配一页内存会导致内存碎片/内存浪费问题，操作系统取巧的设计是将所有碎片共用一段物理内存，但是虚拟出多个不同权限的页

### 环境变量/入参在栈上

---

## 动态链接
优点很多，主要缺点就是牺牲了 5% 的性能

### ld.so
动态链接器，运行应用之前，先把控制权给动态链接器，完全所有动态链接工作后再把控制权返还给应用

这个过程是**递归**的，如果被引用的动态库还引用了其他动态库，动态链接器会继续进行相同的操作

### 动态链接实现难点
编译动态库的时候编译器很难判断一个 extern 符号是属于动态库自身的模块还是说引用了其他动态库的外部符号

所以引入了 .symtab 解决这个问题? .symbol 存储所有符号包括动态库符号, .symtab 只存储动态库相关的符号，两个表差分下就能判断某个 extern 是不是动态库的符号?

### 检查 elf 文件是否 PIC
`readelf -d /usr/lib/x86_64-linux-gnu/libcrypto.so | grep TEXTREL` 没有任何输出则说明 ELF 是 PIC 的

### 多进程不会共享同一动态库静态变量
动态库的全局变量实际上跟进程自身地址空间的全局变量没啥区别，每个进程都是访问的动态库全局变量自己的那个副本，不影响其他进程

所以说动态库的 .data 段实际上是不能被多个进程共用从而节约内存的

但是同一进程的多线程共用一个动态库的静态变量

### __thread thread local storage
ELF 的静态变量定义的时候加上 __thread 就可以做成线程局部静态变量例如 libc 的 errno 达成多线程下错误码的隔离

```
在Rust中，没有类似于C/C++中的__thread关键字来定义线程局部存储的静态变量。Rust的设计理念是通过所有权和借用系统来保证内存安全，而线程局部存储可能会引入一些隐含的安全问题。因此，Rust并没有直接提供线程局部存储的原生支持。

但是，你可以使用thread_local!宏来实现类似的功能
```

Rust 确实有 `#[thread_local]` 属性不过是不稳定的

除了 __thread 这样隐式 TLS 之外，pthread 还提供了 pthread_key_create,pthread_key_delete,pthread_getspecific,pthread_setspecific 四个显式 API，但是这几个 API 有诸多缺点和限制不推荐使用了

### Lazy Binding
为了加速可执行文件启动前动态库加载过程，ELF 采用了延迟绑定的做法，当第一次调用动态库的函数的时候才做该动态库的符号查找、地址重定位等

### 禁用延迟绑定
gcc `-Wl,-z,now` 或者环境变量 `LD_BIND_NOW=1`

检查是否禁用延迟绑定: `readelf -d your_elf | grep BIND_NOW` 如果返回 BIND_NOW 说明禁用了动态绑定

### Procedure Linkage Table
为了实现延迟绑定，调用函数不直接通过 GOT 跳转而是新增一个 PLT 表进行跳转

```asm
foo@plt:
jmp *(foo@GOT)
push n
push moduleID
jump _dl_runtiem_resolve
```

当延迟绑定第一次调用 foo 函数的时候由于 foo@GOT 地址为空所以 jmp 指令不会执行，然后调用 _dl_runtime_resolve 函数解析完后会把地址写入到 foo@GOT 第二次调用就能直接跳转了

### 动态库相关 section
- .dynamic: 本模块动态链接相关信息
- .dynsym: readelf -d 查看，内容类似于动态链接下的 ELF header
- .got: global offset table dynamic symbol resolution during runtime，保存全局变量地址
- .got.plt: 保存函数引用地址，前三项分别是 .dynamic 段地址、本模块 id、_dl_runtime_resolve 函数地址
- .interp: 就存储一个字符串，动态链接库的绝对路径

### linux-gate.so
古老的 Linux 系统中(例如 2.6)为了避免动态链接器在用户空间和内核之间的切换会导致较大的性能开销，引入 gate 的概念让用户态系统调用不需要上下文切换

在现在的 Linux 系统中被 vdso 代替

### .hash
为了加快符号查找过程，所以有了 .hash 索引

### .rel.dyn
类似静态链接用于重定位的 .rel.text 和 .rel.data 的作用

.rel.dyn 对 .got 中数据引用的地址修正

.rel.plt 对函数引用的地址修正

---

### Elf64_auxv_t

栈空间向低地址增长(因此入参从右往左入栈)，进程栈空间从低到高分别是 argc -> argv -> env -> Elf64_auxv_t

所以下面代码要把环境变量指针遍历到头之后才能拿到 elf 辅助数组信息

```c
int main(int argc, char** argv, char* envp[]) {
  Elf64_auxv_t *auxv;
  while(*envp++ != NULL);

  /*from stack diagram above: *envp = NULL marks end of envp*/
  int i = 0 ;
  for (auxv = (Elf64_auxv_t *)envp; auxv->a_type != AT_NULL; auxv++)
    /* auxv->a_type = AT_NULL marks the end of auxv */
  {
    printf("%lu %u %u \n", (auxv->a_type), AT_PLATFORM, i++);
    if( auxv->a_type == AT_PLATFORM)
      printf("AT_PLATFORM is: %s\n", ((char*)auxv->a_un.a_val));
  }
}
```

### Global Symbol Interpose
多个动态库有相同的函数名的话，ld.so 是广度优先搜索，找到的第一个函数会写入全局符号表，忽略后面遇到的重复函数名

烦恼的是动态库多个内部私有函数定义可能被其他库同名函数覆盖，所以一定要避免符号重复，这属于 C 语言开发必须要谨慎小心程序员需要牢记的陷阱

一种解决办法是，遇到重名的时候，把库内部私有的函数/变量加上 static 修饰就达到类似 private 私有函数的效果

### 加载时动态库的 .init/.finit 会不会被重复执行
gpt 说会，所以说要注意动态库 .init 部分代码要设计成可重入多次重复调用无副作用

### dlopen 传入空指针会访问全局符号表
有点像"反射"

### symbol version script
让我痛苦过很长时间的，高版本 glibc 编译出来的 elf 文件无法在低版本系统执行

ld 加上 --version-script 参数可以给生成的符号增加例如 @GLIBC_2.3.3 的后缀

### LD_PRELOAD 实现加速齿轮外挂
ld.so 的缓存有 /etc/ld.so.cache 和 /etc/ld.so.preload

LD_LIBRARY_PATH 原理是设置优先级最高的动态库搜索路径，而 LD_PRELOAD 则是 ld.so 解析动态库之前最先加载的库

由于动态库同名符号不会被覆盖的特点，甚至可以预先加载定制的 sleep 函数覆盖掉 glibc 的函数

```c
// gcc sleep.c -shared -o libsleep.so
#include <stdio.h>
extern unsigned int sleep(unsigned int seconds) {
printf("sleep %d seconds\n", seconds);
}
```

在 LD_PRELOAD 引入我们 sleep.c 魔改的 sleep 函数的动态库之后，应用程序调用 sleep 就不干活啦

### 动态链接库劫持

```console
$ LD_PRELOAD=/path/to/libsleep.so ./a.out
sleep 1 seconds
```

动态链接库劫持比较方便修改系统调用实现，ptrace 繁琐点，更复杂的是，改内核模块源码 hook/patch 内核中的系统调用表

大部分动画引擎都是通过 sleep 来实现 tick 的吧，例如炉石回合制游戏都有无限流无限手牌费用，唯一约束就是回合时间和打出每张牌的动画，因此变速齿轮将 sleep 重写掉，这样动画时间为零又有更多时间打牌达成无限牌无限资源的电表倒转

南大操作系统课介绍外挂原理: <https://jyywiki.cn/OS/2023/build/lect17.ipynb>

```
有操作系统的课讲变速齿轮外挂 篡改sleep系统调用来实现
我用LD_PRELOAD达到类似效果

像回合制游戏有些无限流的构筑(例如酒馆战旗的电表倒转)
唯一限制就是每张卡打出后2s动画时间，一回合时间至多打出20张牌
用变速齿轮掐掉动画时间一回合打两百多张牌
暴雪至今未修复变速齿轮只好砍废掉无限火球卡组
```

### LD_DEBUG=files
LD_DEBUG 的选项还有很多，帮助学习动态库执行流程

### @PLT和@GOT

```
callq memset@PLT和callq memset@GOT在含义上有一些区别。

callq memset@PLT：这是对memset函数的调用，使用了PLT（Procedure Linkage Table）进行函数调用。PLT是一个动态链接的机制，用于在程序运行时解析函数地址。当需要调用memset函数时，会首先跳转到PLT表中的入口，然后再跳转到真正的函数地址。

callq memset@GOT：这是对memset函数的调用，使用了GOT（Global Offset Table）进行函数调用。GOT是一个全局偏移表，用于在程序运行时解析全局变量和函数的地址。当需要调用memset函数时，会直接从GOT表中获取函数地址。

在使用这两种调用方式时，PLT表和GOT表会在程序运行时被填充和更新。PLT表会在首次调用函数时进行函数地址的解析，然后将地址缓存到GOT表中，以便后续的调用可以直接从GOT表中获取函数地址，避免了重复的解析过程。

总的来说，callq memset@PLT使用了两级跳转的方式进行函数调用，而callq memset@GOT直接从GOT表中获取函数地址进行调用。在绝大多数情况下，这两种方式的性能差异很小，具体使用哪种方式取决于编译器和链接器的设置。
```

---

## .ctor 段

atexit 函数有点像 defer 的感觉，会在 main 函数结束后执行，一般用来释放资源等

main 函数之前的 _init() 实际上调用 _do_global_ctors_aux 函数是与 C++ 中全局构造函数（global constructors）相关的一个函数

__CTOR_LIST__ 全局构造函数的数组指针

##  /usr/lib/x86_64-linux-gnu/crti.o

C 语言运行库环境，无论 c 静态还是动态链接都会链接这个访问在程序运行前执行

可以用 -nostdlib -nostartfile 不加载这个运行库

## asmlinkage = __attribute((regparm(0)))
这是内核源码的一个宏，表示函数只从栈上获取入参，避免用寄存器传递入参，适用于中断上下文切换避免污染寄存器的场合

---

## clang AddressSanitizer

> clang -fsanitize=address -O1 -fno-omit-frame-pointer -g   tests/use-after-free.c

对应 Rust 的编译器 flag 是 RUSTFLAGS=-Zsanitizer=address

但不适用于有过程宏的项目 libserde_derive-56d82479fb854012.so: undefined symbol: __asan_option_detect_stack_use_after_return

## 超线程/超标量/流水线

以我 AMD 5900X 为例子，主板一个 CPU 插槽因此只有一个 numa

lscpu 返回 10 cores per socket 表示这个处理器插槽有 10 个物理核心，但由于超线程技术每个物理核心模拟出 20 个逻辑内核

CSAPP 上超标量的定义: 如果处理器可以达到比一个周期一条指令更快的执行速率，就称之为超标量

所以说流水线或者 SIMD 也算是超标量
