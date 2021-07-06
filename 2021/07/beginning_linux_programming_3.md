# [BLP读书笔记3](/2021/07/beginning_linux_programming_3.md)

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

#### /proc/cpuinfo, /proc/version文件

像`/proc/cpuinfo`这类文件都是 **empty** 的，「只当有进程想读/proc/cpuinfo时」才会从硬件获取数据

所以每次读取的CPU各个核当前主频都是瞬时值

!> 不要sudo权限往`/proc/cpuinfo`瞎写数据，一旦数据格式不对系统就挂掉

所以用户态程序可以认为 /proc/cpuinfo 这类文件都是只读的，千万不能写

#### /proc/net/sockstat

网卡硬件的重要信息，后续学socket编程再慢慢理解该文件各项数值的含义


