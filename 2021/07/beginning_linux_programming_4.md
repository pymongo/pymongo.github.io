# [BLP 读书笔记 4](/2021/07/beginning_linux_programming_4.md)

## ch05 terminal part2

### stty non-canonical

> stty -icanon min 1 time 0

`min 1` 表示一旦读到一个字符就立即处理

例如输入密码时可以把ECHO flag关掉，输入完密码再打开

### 设置terminal的I/O波特率(serial port)

cfsetispeed 和 cfsetospeed

### menu4.c

ISIG可以禁用Ctrl+C这种特殊控制符的输入

> c_lflag &= ~ISIG

### /usr/share/terminfo

存储各种terminal标准的参数的"数据库"

### sizeterm.c

获取当前terminal的长宽是，单位是字符，setupterm(NULL,...)， NULL表示选用当前terimnal规格(通过环境变量$TERM)，或者填入其它terminal名称的字符串

### menu5.c

用terminal坐标去一个个修改字符显示太原始了，不那么重要的代码示例先跳过不细看也不值得敲一遍

### kbhit.c

一次读stdin一个字符来检测按键，没法检测组合按键，所以先跳过不细看也不值得敲一遍

### virtual console /dev/ttyN

Ctrl+Alt+F1/F2 就是切换cli和desktop两个环境的virtual console

### /dev/pts pseudo-terminals

---

## ch06 curses

除了第1-2个代码示例，其余代码全跳过，内容介绍和API也是粗略扫过

### update screen

call curses() replace curscr(current screen) to stdscr(your define next screen)

and then call refresh()

---

## ch07 Data Management

### memory

Linux除非是嵌入式应用，都不允许访问真实的物理内存地址(有虚拟内存映射)

### 「重要」open的互斥锁参数

libc::open的flags参数的**O_EXCL**标志表示以互斥锁的形式打开，exclusive mutex

可以通过以下方式模拟Cargo的互斥锁:

> ./a.out & ./a.out

例如前一个进程的前10秒拿到互斥锁文件，后一个进程只能不断轮询等10秒后才能 exclusive access

The lock file acts as a **binary semaphore**

注意避免死锁，例如前一个进程报错提前中止没有把锁文件删掉，后一个进程就一直acquire不到锁

### 「重要」lock region

例如有一个很大的视频文件，多个进程同时不同的时间轴转码剪辑

为了让各个进程负责的部分互不干扰，可以用「更细粒度的锁」，锁住文件的一部分数据

!> 注意fnctl和lockf的锁不能混用，二者不会互相识别

### lock region不要用fread/fwrite

例如锁住并读写100bytes，因为fread/fwrite内部有个BUFSIZ，所以会读超过100bytes直到BUFSIZ，

导致无法精准控制 锁住读写100bytes的效果

### 「重要」fnctl 读写锁和所有权

l_type字段有三种状态：无锁、写锁(所有权的独占引用,exclusive)、读锁(shared)

跟所有权和RwLock一样: 同一时刻某个文件的同一段区间的数据，要么只有一个WLock可变引用，

总结下区别就是

- RLock: shared immutable lock
- WLock: exclusive mutable lock

### 「重要」advisory 的含义

非强制的锁，其它进程依然可以读写(只要不用fnctl)，这也是为啥fnctl和flock两个锁不是互通的原因

### 「重要」deadlock

进程A按顺序文件byte1,byte2的顺序加互斥锁修改文件，而进程B则反之按byte2,byte1的顺序，因此这两个进程会出现死锁

进程A等进程B释放byte2的锁，进程B又在等进程A释放byte1的锁

### dbm数据库的应用

dbm是一个单文件的key-value数据库，RedHet/CentOS/OpenSUSE发行版的rpm格式二进制包分发，具体例子看我代码示例

---

## ch08 mysql

安装mysql和创建用户看我manjao_kde_config.md的文章

### 查看mysql服务器信息

> mysql -? # 最详细的服务器信息

或

> mysql> \s

或

> sudo mysqladmin -uroot -p version

查看mysql运行参数和当前配置: `sudo mysqladmin variables | more`

### mysql配置文件路径

> /etc/my.conf.d

### mysql -uroot -ppassword为什么不安全

其它用户可以通过 bash history 查看你输入的密码，很不安全

### 子网掩码mask

> mysql> GRANT ALL ON *.* TO ethernet@'192.168.1.0/255.255.255.0' IDENTIFIED BY 'password';

'192.168.1.0/255.255.255.0' 表示 192.168.1.* 网段的客户端可以用 ethernet 的用户名登陆，密码是 password

'%.example.com' 表示 *.example.com 的域名

In SQL syntax, the special character % is a wildcard character, much the same as * in a shell

### mysqlshow 快速查看表结构

mysqlshow跟上auth相关信息后，可以加 数据库名-表名字-字段名参数

> mysqlshow -uw -pw mysql user user

如果只加数据库名，就列出数据库的所有表，以此类推

### GRANT语句的字符串不要带下划线

`%`类似`*`表示匹配任意字符，GRANT语句的`_`能匹配一个任意字符

跟 grant 命令相对的是 revoke 去除权限

---

## ch09 development tools

### make

make 构建工具主要解决构建多源文件的 C 项目、编译中间产物、编译顺序、编译依赖和增量编译等问题

make 不加任何参数时默认会构建 Makefile 中的第一个 target

大伙有个约定就是第一个 target 一定是 all

#### 「重要」make宏文本替换

语法和用法类似 bash 类似，原理就是 C 语言 #define 那样的文本替换

make 能根据编译源文件和编译产物的后缀名自动生成编译命令

```
$target = debug (or release)

build: src/main.rs
    cargo b --$(target)
```

类似 bash 自带的几个 $ 变量，make 也有几个:
- $?: list all prerequisites
- $@: name of the current target(output filename)
- $<: name of the current prerequisites(input filename)
- $*: name of the current prerequisites without any suffix

#### 「重要」make的`@`和`-`和`\`

- `\`: 由于make每个命令都会开新的子shell,如果命令前后有依赖关系则用 `\` 连起来保证在同一个shell中执行(all passed together to a single invocation of the shell for execution)
- `@`: 类似 bash `set +o xtrace`
- `-`: 隐藏错误

`chmod og-rwx`中的o表示other,g表示group

make install想要装到其它目录时要用

#### 「重要」gcc的-MM参数

列出gcc入参之间的依赖(供make使用)

```
$ gcc -MM main.c 2.c 3.c
main.o: main.c a.h
2.o:2.c a.h b.h
3.o: 3.c b.h c.h
```

### 编写man文档

my_command.1 的`.1`后缀表示是 man section 1 分类的文档

```
.TH MYAPP 1
.SH SEE ALSO
rust
```

渲染man格式文档的命令groff:

> groff -Tascii -man my_command.1

```
MYAPP(1)                    General Commands Manual                   MYAPP(1)



SEE ALSO
       rust
```

可以把文档文件放在这个目录就能被man命令识别`/usr/share/man/man1/`

### 「重要」patch命令

类似git patch能根据git diff文件进行代码改动

git patch -R 表示回滚变更

### 「重要」tar命令

参数很多，建议只用记两个，tar打包后自行再用gzip命令去压缩，gzip -r 解压

首先-f参数是必加的，表示打包和解包对象都是文件

> tar cf pwd.tar . # 打包: c表示create
> 
> tar xf pwd.tar # 解包: x表示Extracts

参数v只是用来显示打包时包含的文件，不要记那么复杂

只用记打包用c解包用x,f都要加

---

## ch010 debugging

由于 gdb 超级重要，所以单独建了一个 `gdb.md` 记录 gdb 经验

### 「重要」C/C++工具生态(非静态分析)

- 开源IDE: qt_creator, kdeveloper
- cargo-fmt: clang-format
- repl/jit: root/cling

### 「重要」C/C++静态分析工具

- splint, Linux version of Unix lint
- clang-tidy/clazy-standalone(llvm): clang-tidy在CLion中广泛使用
- ctags: 寻找函数/变量定义，帮助emacs/IDE跳转到函数定义
- cxref: 寻找 #define 等符号的定义
- cflow: **callgraph** 打印「静态」函数调用树(function call tree)
- cppcheck
- prof/gprof

### ctags列出所有ident的定义处

```
[w@ww chapter10]$ ctags -x debug0.c 
__anon113c782d0108 struct        1 debug0.c         /* 1 */ typedef struct {
array            variable      6 debug0.c         /* 6 */ item array[] = {
data             member        2 debug0.c         /* 2 */ char *data;
item             typedef       4 debug0.c         /* 4 */ } item;
key              member        3 debug0.c         /* 3 */ int key;
main             function     34 debug0.c         /* 34 */ main()
sort             function     14 debug0.c         /* 14 */ sort(a,n)
```

### cflow print callgraph

```
[w@ww chapter10]$ cflow debug0.c 
main() <main () at debug0.c:34>:
    sort() <sort (a, n) at debug0.c:14>
```

### 「重要」gprof动态分析工具

gcc 或 clang 的 `-pg` 参数能像依赖注入一样注入一些监控的代码，例如监控函数调用次数，运行耗时

> gcc -pg main.c
> 
> ./main # mon.out is generate after run
> 
> gprof

注意要程序运行后才会生成 monitor data `mon.out`，或者直接用 `gprof ./a.out`

Rust 有一个部分支持 gprof 的 [PR: Add -Z instrument-mcount](https://github.com/rust-lang/rust/pull/57220)

很可惜即便 LLVM 的 clang 支持 -pg 参数，Rust 加上类似的参数运行后也不能生成 mon.out 分析数据

想让 Rust 兼容 gprof 的项目有很多，但是目前来看只有 uftrace 比较可行

### 「重要」uftrace

> yay -S uftrace-git

> rustc -g -Z instrument-mcount main.rs

uftrace 用法一: 追踪可执行文件的函数调用耗时

> uftrace ${executable_filename}

```
[w@ww chapter10]$ uftrace ./main
# DURATION     TID     FUNCTION
            [841769] | std::rt::lang_start() {
            [841769] |   std::rt::lang_start::_{{closure}}() {
            [841769] |     std::sys_common::backtrace::__rust_begin_short_backtrace() {
            [841769] |       core::ops::function::FnOnce::call_once() {
            [841769] |         main::main() {
            [841769] |           main::fib() {
            [841769] |             main::fib() {
            [841769] |               main::fib() {
            [841769] |                 main::fib() {
   0.070 us [841769] |                   main::fib();
   0.040 us [841769] |                   main::fib();
```

uftrace 用法二: 先 record 保存数据，再导出成不同格式

> uftrace record ./main

然后可以看看函数调用树 **callgraph**

注意这是程序动态的函数调用树会有虚函数这样动态的调用，比 `cflow` 这种纯静态分析函数调用树真实多了

有了 uftrace record 数据后，可以转换成以下三种格式

#### graphviz 格式

> sudo pacman -S xdot # gnome/gtk graphviz render tool

> uftrace dump --graphviz > ~/temp/uftrace_graphviz.dot && xdot ~/temp/uftrace_graphviz.dot

#### chrome://tracing json 格式

> uftrace dump --chrome > ~/temp/uftrace_chrome_tracing.json

然后在 `chrome://tracing` 页面导入刚刚 uftrace 生成的 json 文件

#### 火焰图格式

> yay -S flamegraph-git

> uftrace dump --flame-graph | flamegraph > ~/temp/uftrace_flamegraph.svg && google-chrome-stable ~/temp/uftrace_flamegraph.svg

---

```
总结 火焰图分析 Rust 程序的流程:

安装所需工具:
yay -S uftrace-git flamegraph-git

运行步骤:
1. rustc -g -Z instrument-mcount main.rs
2. uftrace record ./main
3. uftrace dump --flame-graph | flamegraph > ~/temp/uftrace_flamegraph.svg && google-chrome-stable ~/temp/uftrace_flamegraph.svg
```
