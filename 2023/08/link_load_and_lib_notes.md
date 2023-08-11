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

看书/代码看到 link_section link(weak) 这些 ABI 相关的属性宏
整理了下发现都能找到 C 语言一一对应的 __attribute__

注意 `extern "C"` 是 C++ 专有语法，因此用的时候经常套上 `#ifdef __cplusplus`

~~链接的时候如果有多个 weak symbol 则会选择占用空间最大的一个~~ 书中这个说法跟 gpt 不一致，gpt 说选择 ld 入参文件顺序的第一个 week symbol

### weak/weak_ref
weak 还有一个用法是判断编译时有没有加上 -lpthread 从而让业务代码走单线程分支还是多线程分支

如果没有加 -lpthread 则 weak symbol 指针为 0 以此判断是否 -lpthread

---

## 超线程/超标量/流水线

以我 AMD 5900X 为例子，主板一个 CPU 插槽因此只有一个 numa

lscpu 返回 10 cores per socket 表示这个处理器插槽有 10 个物理核心，但由于超线程技术每个物理核心模拟出 20 个逻辑内核

CSAPP 上超标量的定义: 如果处理器可以达到比一个周期一条指令更快的执行速率，就称之为超标量

所以说流水线或者 SIMD 也算是超标量
