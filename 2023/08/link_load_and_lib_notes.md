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

### 动态库相关 section
.dynamic: 动态链接信息  
.got: global offset table dynamic symbol resolution during runtime

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
|C++: extern "C"|#[no_mangle]|
|`__attribute__((constructor))`||

注意 `__attribute__((section(".bss")))` 在 visual studio 工具链上可用 `#pragma data_set(".bss")`

注意 `extern "C"` 是 C++ 专有语法，因此用的时候经常套上 `#ifdef __cplusplus`

~~链接的时候如果有多个 weak symbol 则会选择占用空间最大的一个~~ 书中这个说法跟 gpt 不一致，gpt 说选择 ld 入参文件顺序的第一个 week symbol

看书/代码看到 link_section link(weak) 这些 ABI 相关的属性宏
整理了下发现都能找到 C 语言一一对应的 __attribute__

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
