# [BLP 读书笔记 3](/2021/07/beginning_linux_programming_3.md)

## ch3 files part2

### TIMEFORMAT

可以通过TIMEFORMAT控制shell函数time的输出格式

!> 注意 bash 和 zsh 的 time 输出不一样(书中的time输出更像是zsh的time函数)

bash的time的输出会受到TIMEFORMAT的影响，但是zsh似乎不受TIMEFORMAT影响

这是ch03/copy_system.c第一个版本，同样的代码C和Rust实现zsh的time性能测试:

```
             ./copy_system  0.05s user 1.51s system 99% cpu 1.562 total
./target/debug/copy_system  0.04s user 1.08s system 99% cpu 1.117 total
```

### libc::lseek set fd cursor

lseek能改变某个fd读写的当前位置(cursor)

lseek有三个参数: fd, 定位标准, 位置偏移。返回值是cursor移动到的新位置(如果成功)

可以根据文件开头/结尾/当前位置三个基准进行定位(relative position)

### dup/dup2 duplicating fd

might be used for reading and writing to different locations in the file

dup is useful in process communication via pipe

### fgets/gets

stdio.h的API内部维护了一个buffer,所以可能没有libc::read或libc::write性能好

`char* fgets(char *ret, int buf_len, File *stream)`

从File中读取一个字符串，遇到EOD或\n或已经读了buf_len-1个byte 就会return

而 gets 就等于 fgets(char* ret, stdin)，因此 gets 是一个不安全的长度

因为 gets 没有buf长度信息，一旦stdin输入过长就有缓冲区溢出的UB

### scanf 示例

scanf会忽略入参format中的空格，也会忽略输入的空格或换行

这样会导致stdin如果一直没有数字输入，进程就会hang(阻塞)

例如以下代码stdin输入"a 1 2"或"  a 1    2"都能运行正常

scanf的返回值则是一共有几个变量被成功赋值

```rust
let mut a: i32 = 0;
let mut b: i32 = 0;
let ret = unsafe { libc::scanf("a %d %d\0".as_ptr().cast(), &mut a, &mut b) };
```

显然sscanf从字符串中parse一个整数可能会溢出，parse一个字符串怕`[u8]`越界

### fgetpos/ftell/rewind

都是文件读写cursor位置相关的API，fgetpos是whence为SEEK_SET(参考坐标是文件开头)的ftell

rewind则是把cursor设置成文件开头，等于`fseek(stream, 0L, SEEK_SET)`

### 「重要」hard/symbolic link

#### 「重要」link

link(hard link)创建方法:
1. ln link_target new_link_file
2. link link_target new_link_file
3. libc::link(link_target, new_link_file)

link命令`link FILE1 FILE2`可以创建一个FILE2链接到FILE1，调用的link系统调用

注意创建的FILE2并不是link软链接类型的文件，还是跟FILE1保持一样的文件类型，并且相同的inode

由于FILE1和FILE2的inode是一样的，因此修改FILE1，FILE也会进行相同的变更

#### 「重要」创建symlink

symlink的创建方法:
1. ln -s link_target new_link_file
2. libc::symlink(link_target, new_link_file)

### 「重要」unlink/remove删除文件

remove等于unlink非dir文件，unlink既可以删文件夹也可以删文件

#### 「重要」怎么理解删除文件

假设被删文件的路径是path, 指向的inode是inode_n

删除文件只是删掉path指向inode_n的link，然后inode_n links减1

直到 inode_n 的所有link都被unlink掉了，而且没有进程打开 inode_n ，那么 inode_n 的硬盘空间就会被 free

#### 什么时候清理被删文件的硬盘空间

unlink system remove the directory entry for a file, and links -= 1

if links=0, and all process close this file, then free the disk space of file

所以这也是为什么删除当前terminal打开文件夹的时，并不会像windows那样报错"另一个进程正在使用，无法删除"

#### 文件夹需要可执行权限

!> cd directory or delete file in directory need executable permission for directory

如果目录没有可执行权限，无法cd进去，也不能删除目录内的文件

### disk DMA mode

DMA aka Direct Memory Access, 由主板上的控制器管理

> A network card might be able to report whether it has negotiated a high-speed, duplex connection.

翻译: 网卡可以运行在一个协商好的高速双工通信连接

### 「重要」proc filesystem

#### special regular empty file

Example: /proc/cpuinfo, /proc/version, /proc/$PID/environ

- 零大小无状态空白文件
- only read permission
- fetch current value when read it

#### /proc/cpuinfo

因为cpuinfo都是读取时抓取硬件的瞬时值，所以每次读取的CPU各个核当前主频都是瞬时值、

!> 不要sudo权限往`/proc/cpuinfo`瞎写数据，一旦数据格式不对系统就挂掉

#### /proc/net/sockstat

网卡硬件的重要信息，后续学socket编程再慢慢理解该文件各项数值的含义

#### 进程文件夹的重要文件

- environ，进程当前的环境变量，跟`/proc/cpuinfo`一样默认是空白，root用户才有写权限，只有读取时才会抓取数据
- cmdline，进程当前运行中的可执行文件名，跟`/proc/cpuinfo`一样默认是空白，root用户才有写权限，只有读取时才会抓取数据

例如当前进程是从bash进入的python shell,读cmdline会返回python

### 「重要」mmap

作用: 将文件映射成一段连续的内存，进程高速读写这段内存，再手动将数据同步回文件中

应用举例:
- 数据库
- 硬件IO文件映射到内存，例如树莓派
- shared memory

例如数据库可以通过mmap将`[T; N]`同一张表的所有记录映射到一段内存中，再制定某个文件进行持久化

数据读写的单位例如是一个结构体，mmap比fread/fwrite读写结构体到文件中快得多

---

## ch04 linux environment

### getopt/getopt_long

Linux 自带命令就是靠这两个系统调用实现任意顺序的参数也能被解析

### getenv

getenv获取到的环境变量的所有权在getenv,为了后续使用建议strdup复制一份自己用

### 「重要」tmpnam/tmpfile

db need a temp file when delete records, temp file collects the db entries that need to be retained, after retain write temp file back to db

例如 ch02 的 CD 应用代码就是 `grep exclude` 将要保留的csv数据存入临时文件中，然后再写入回来

#### 「重要」tmpnam

generate a random unique filename like `/tmp/fileFR8UhK`

warning: the use of tmpnam is dangerous, better use mkstemp

因为 tmpnam 不像 tmpfile 创建后立即打开，所以会有线程安全问题，不保证文件名一定不重复

#### 「重要」tmpfile

创建一个随机名字的临时文件并打开(应该也像tmpnam一样临时存在/tmp目录)，

返回一个`File *`，文件指针close之后会自动删掉该文件

#### 「重要」mktemp

安全版tmpnam，支持自定义文件名前缀，mkdtemp则是创建文件夹，参考以下示例:

```rust
extern "C" {
    fn mktemp(template: *mut libc::c_char) -> *mut libc::c_char;
}
let mut template = *b"/tmp/connection_XXXXXX\0";
let mktemp_ret = mktemp(template.as_mut_ptr().cast());
libc::printf("mktemp_ret = %s\n\0".as_ptr().cast(), mktemp_ret);
let fd = libc::open(mktemp_ret, libc::O_CREAT, libc::S_IRUSR | libc::S_IWUSR);
if fd == -1 {
    libc::perror("open\0".as_ptr().cast());
    panic!();
}
if libc::close(fd) == -1 {
    libc::perror("close\0".as_ptr().cast());
    panic!();
}
if libc::unlink(mktemp_ret) == -1 {
    libc::perror("unlink\0".as_ptr().cast());
    panic!();
}
```

#### 「重要」mkstemp

similar to mktemp, but return a fd, need to manual delete(not like tmp file auto delete)

### get user info

#### getlogin

return current login username

#### 为什么/etc/passwd能隐藏密码

/etc/shadow好像是个配置文件，能让/etc/passwd中的所有密码都显示成`x`，术语叫「shadow password file」

### getpwent遍历/etc/passwd

```rust
loop {
    let entries = libc::getpwent();
    if entries.is_null() {
        break;
    }
    libc::printf("%s\n\0".as_ptr().cast(), (*entries).pw_name);
}
```

### 进程信息

#### 「重要」进程优先级

类似 windows 任务管理器设置进程优先级

不过 KDE 的 ksysguard 进程管理器的进程优先级有两个设置，一个是IO优先级不能改，一个是CPU调度优先级

普通用户好像只能调低进程优先级，不能进程低优先级变高优先级

> libc::getpriority(libc::PRIO_PROCESS, libc::getpid() as u32)

0是默认的进程优先级，负数表示优先级更高，正数则反之表示优先级低

优先级的范围是 [-20, 20]

通过 nice 命令可以修改进程的优先级

### 「重要」rlimit

#### pathconf获取文件名长度限制

#### 「重要」soft/hard limits

ulimit只是个bash的函数

系统级的配置文件在 `/etc/security/limits.conf`

**soft limit** 到达时会警告，而且一些库或系统调用会报错

**hard limit** 操作系统会直接发 signal 中止进程

所以一般 limits.conf 需要同时吧soft/hard limit改成一样的

例如limits.c例子中通过setrlimit将文件大小限制为2k

结果收到了 SIGXFSZ 终止信号，并且退出码是 153 ('128+n'>>>Fatal error signal "n")

---

## ch05 terminal part1

bash shell arranges for the STDOUT/STDIN streams to be connected to your program

#### 「重要」C语言结构体数组也有NULL terminator

例如字符串也是一种一维数组，又例如

```cpp
char *menu[] = {
    "a - add new record",
    "q - quit",
    NULL,
};
```

#### canonical/standard or non-canonical mode

canonical: 规范化

- canonical mode: 用户以行输入为单位进行输入，例如 getchar 直到按回车才能被应用进程读取
- non-canonical node: 例如 vim/emacs 能立即得知用户的键盘按键

#### 换行符

行输入模式需要通过换行符来识别，例如 CR(carriage return) 和 LF(line feed)

#### isatty: check fd connect to a terminal

可以用来检查用户有没有把STDOUT重定向到文件，否则交互式应用没法将输出显示到terminal

推荐自行将字符串从 /dev/tty 中读写，这样哪怕用户重定向STDOUT到文件中也能进行交互

#### tcgetattr/tcsetattr termios

以前的电脑可能要电话线+调制解调器(parity奇偶校验之类的)传递terminal的信号，一台大型机器，多个terminal终端

tcgetattr/tcsetattr 可以通过 termios 修改 terminal 行为（例如立即读取键盘输入而非行输入） (似乎需要链接curses库)

!> 注意修改termios一定要备份，退出程序时再还原

当前terminal的termios配置可以通过`stty -a`命令大致查看

或者用`stty -g`导出当前的terminal配置

#### 「重要」Ctrl+J等于换行

以后 tail -f 看日志时，可以用 `Ctrl+J` 代替回车进行清屏幕，比回车键好按多了

#### 「重要」Ctrl+S暂停terminal的output,Ctrl+Q恢复
