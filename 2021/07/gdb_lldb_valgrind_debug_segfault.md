# [gdb/lldb 调试 segfault](2021/07/gdb_lldb_debug_segfault.md)

## 目录

首先通过一个 segfault 的案例，介绍以下工具如何分析该案例的内存错误:
- coredumpctl
- dmesg
- valgrind
- gdb
- lldb
- vscode-lldb
- Intellij-Rust

然后介绍上述工具再分析几个内存错误案例:
- SIGABRT/double-free
- (TODO)SIGABRT/free-dylib-mem

## segfault 案例和调试工具

以下是我重写 ls 命令的部分源码(以下简称`ls 应用`)，完整源码在[这个代码仓库](https://github.com/pymongo/linux_commands_rewritten_in_rust/blob/main/examples/sigsegv_opendir_open_null.rs)

```rust
fn main() {
    let dir = unsafe { libc::opendir(input_filename.as_ptr().cast()) };
    loop {
        let dir_entry = unsafe { libc::readdir(dir) };
        if dir_entry.is_null() {
            break;
        }
        // ...
    }
}
```

跟原版 ls 命令一样，输入参数是一个文件夹时能列出文件夹内所有文件名

但当 ls 应用的参数不是文件夹时，就会 segfault 内存段错误:

```
> cargo r --bin ls -- Cargo.toml 
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/ls Cargo.toml`
Segmentation fault (core dumped)
```

### coredumpctl

#### systemd-coredump 配置

首先查看系统配置文件 `/proc/config.gz` 看看是否已开启 coredump 记录功能

```
> zcat /proc/config.gz | grep CONFIG_COREDUMP
CONFIG_COREDUMP=y
```

由于 `/proc/config.gz` 是 *gzip* 二进制格式而非文本格式，所以要用 `zcat` 而非 `cat` 去打印

再看修改 coredumpctl 配置文件 `/etc/systemd/coredump.conf`

把默认的 coredump 日志大小限制调到 20G 以上: `ExternalSizeMax=20G`

然后重启: `sudo systemctl restart systemd-coredump`

#### 查看最后一条 coredump 记录

通过 `coredumpctl list` 找到最后一条 coredump 记录，也就是刚刚发生的 segfault 错误记录

> Tue 2021-07-06 11:20:43 CST 358976 1000 1001 SIGSEGV present  /home/w/repos/my_repos/linux_commands_rewritten_in_rust/target/debug/ls  30.6K

注意用户 id 1000 前面的 358976 表示进程的 PID，用作 `coredumpctl info` 查询

> coredumpctl info 358976

```
           PID: 358976 (segfault_opendi)
// ...
  Command Line: ./target/debug/ls
// ...
       Storage: /var/lib/systemd/coredump/core.segfault_opendi.1000.d464328302f146f99ed984edc6503ca0.358976.1625541643000000.zst (present)
// ...
```

也可以选择用 gdb 解析 segfault 的 coredump 文件:

`coredumpctl gdb 358976` 或者 `coredumpctl debug 358976`

参考: [core dump - wiki](https://wiki.archlinux.org/title/Core_dump)

### dmesg 查看 segfault 记录

`sudo dmesg` 能查看最近几十条内核消息，发生 segfault 后能看到这样的消息:

> [73815.701427] ls[165042]: segfault at 4 ip 00007fafe9bb5904 sp 00007ffd78ff8510 error 6 in libc-2.33.so[7fafe9b14000+14b000]

### valgrind 检查内存错误

> valgrind --leak-check=full ./target/debug/ls

```
// ...
==356638== Process terminating with default action of signal 11 (SIGSEGV): dumping core
==356638==  Access not within mapped region at address 0x4
==356638==    at 0x497D904: readdir (in /usr/lib/libc-2.33.so)
==356638==    by 0x11B64D: ls::main (ls.rs:15)
// ...
```

### gdb 调试分析错误原因

§ gdb 打开 ls 应用的可执行文件:

> gdb ./target/debug/ls

§ gdb 通过 `l` 或 `list` 命令打印可执行文件的代码:

> (gdb) l

§ gdb运行 ls 应用且传入 `Cargo.toml` 文件名作为入参:

> (gdb) run Cargo.toml

```
Starting program: /home/w/repos/my_repos/linux_commands_rewritten_in_rust/target/debug/ls Cargo.toml
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Program received signal SIGSEGV, Segmentation fault.
0x00007ffff7e5a904 in readdir64 () from /usr/lib/libc.so.6
```

§ 查看 segfault 发生时的栈帧

> (gdb) backtrace

```
#0  0x00007ffff7e5a904 in readdir64 () from /usr/lib/libc.so.6
#1  0x0000555555568952 in ls::main () at src/bin/ls.rs:15
```

此时已经找到出问题的系统调用函数是 `readdir64`，上一个栈帧在 `ls.rs` 的 15 行

$ 查看问题代码的附近几行

> (gdb) list 15

§ 查看问题栈帧的局部变量

- `info variables` 能打印全局或 static 变量
- `info locals` 打印当前栈帧的局部变量
- `info args` 打印当前栈帧的入参

> (gdb) frame 1 # select frame 1
> 
> (gdb) info locals

```
(gdb) frame 1
#1  0x0000555555569317 in ls::main () at src/bin/ls.rs:20
20              let dir_entry = unsafe { libc::readdir(dir) };
(gdb) info locals
dir = 0x0
// ...
```

此时发现 main 栈帧的 `dir = 0x0` 是空指针，导致 readdir 系统调用 segfault

#### 分析错误原因

```rust
let dir = unsafe { libc::opendir(input_filename.as_ptr().cast()) };
loop {
    let dir_entry = unsafe { libc::readdir(dir) };
    // ...
}
```

问题出在没有判断 `opendir` 系统调用是否成功，系统调用失败要么返回 NULL 要么返回 -1

如果 `opendir` 系统调用传入的文件类型不是 directory，就会调用失败

因此 Bug 解决方法是 **检查上游的 opendir 创建的 dir 变量是否为 NULL**

#### 解决 segfault

只需要在加上 dir 是否为 NULL 的代码，如果为 NULL 则打印系统调用的错误信息

```rust
if dir.is_null() {
    unsafe { libc::perror(input_filename.as_ptr().cast()); }
    return;
}
```

再次测试 ls 应用读取非文件夹类型的文件

```
> cargo r --bin ls -- Cargo.toml 
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/ls Cargo.toml`
Cargo.toml: Not a directory
```

此时程序没有发生段错误，并且打印了错误信息 `Cargo.toml: Not a directory`

关于修复 ls 应用 segfault 的代码改动[在这个 commit](https://github.com/pymongo/linux_commands_rewritten_in_rust/commit/b5f92f85ab1949e04ac713ad079d4359760e1cd1)

参考 gnu.org 的官方教程: <https://www.gnu.org/software/gcc/bugs/segfault.html>

### lldb 调试

lldb 调试和 gdb 几乎一样，只是个别命令不同

> (lldb) thread backtrace # gdb is `backtrace`

```
error: need to add support for DW_TAG_base_type '()' encoded with DW_ATE = 0x7, bit_size = 0
* thread #1, name = 'ls', stop reason = signal SIGSEGV: invalid address (fault address: 0x4)
  * frame #0: 0x00007ffff7e5a904 libc.so.6`readdir + 52
    frame #1: 0x0000555555568952 ls`ls::main::h5885f3e1b9feb06f at ls.rs:15:34
// ...
```

> (lldb) frame select 1 # gdb is `frame 1`

```
frame #1: 0x0000555555569317 ls`ls::main::h5885f3e1b9feb06f at ls.rs:15:34
   12       
   13       let dir = unsafe { libc::opendir(input_filename.as_ptr().cast()) };
   14       loop {
-> 15           let dir_entry = unsafe { libc::readdir(dir) };
   16           if dir_entry.is_null() {
   17               // directory_entries iterator end
   18               break;
```

§ lldb 变量打印上 `frame variable` 等于 gdb 的 `info args` 加上 `info locals`

`(gdb) info args` 等于 `(lldb) frame variable --no-args`

除了 **primitive types**, lldb 还可以打印 String 类型变量的值，但是无法得知 `Vec<String>` 类型变量的值

### vscode-lldb 调试

不打任何断点运行程序时，会指向以下代码

> 7FFFF7E5A904: 0F B1 57 04                cmpxchgl %edx, 0x4(%rdi)

此时应当关注 vscode 左侧 Debug 侧边栏的 `CALL STACK` 菜单 (也就 gdb backtrace)

call stack 菜单会告诉 readdir 当前汇编代码的上一帧(也就是 backtrace 第二个栈帧)是 main 函数的 15 行

点击 main 栈帧，相当于 `(gdb) frame 1`，就能跳转到出问题的源码所在行了

在 main 栈帧 下再通过 variable 菜单发现 readdir 传入的 dir 变量值为 NULL 导致段错误

### Intellij-Rust 调试

Debug 运行直接能跳转到问题代码的所在行，并提示 `libc::readdir(dir)` 的 dir 变量的值为 NULL

---

熟悉上述调试工具，可以接下来看几个内存错误的案例

## SIGABRT/double-free 案例分享

以下是 tree 命令深度优先搜索遍历文件夹的代码(省略部分无关代码，[完整源码链接在这](https://github.com/pymongo/linux_commands_rewritten_in_rust/blob/main/examples/sigabrt_closedir_wrong.rs))

```rust
unsafe fn traverse_dir_dfs(dirp: *mut libc::DIR, indent: usize) {
    loop {
        let dir_entry = libc::readdir(dirp);
        if dir_entry.is_null() {
            let _sigabrt_line = std::env::current_dir().unwrap();
            return;
        }
        // ...
        if is_dir {
            let dirp_inner_dir = libc::opendir(filename_cstr);
            libc::chdir(filename_cstr);
            traverse_dir_dfs(dirp_inner_dir, indent + 4);
            libc::chdir("..\0".as_ptr().cast());
            libc::closedir(dirp);
        }
    }
}
```

这段代码运行时会报错:

```
malloc(): unsorted double linked list corrupted

Process finished with exit code 134 (interrupted by signal 6: SIGABRT)
```

通过 gdb 调试能知道 `std::env::current_dir()` 调用报错了，但错误原因未知

### 经验: SIGABRT 可能原因

通过上述段错误的分析，我们知道 SIGSEGV 可能的原因是例如 `readdir(NULL)` 解引用空指针

根据作者开发经验，SIGABRT 的可能原因是 **double free**

### valgrind 检查 double free

顺着 double-free 的思路，通过 valgrind 内存检查发现，`libc::closedir(dirp)` 出现 InvalidFree/DoubleFree 的内存问题

### 分析 double free 原因

再细看源码，递归调用前创建的是子文件夹的指针，递归回溯时却把当前文件夹指针给 close 掉了

这就意味着，一旦某个目录有 2 个以上的子文件夹，那么当前的文件夹指针可能会被 free 两次

进而将问题的规模简化成成以下三行代码:

```rust
let dirp = libc::opendir("/home\0".as_ptr().cast());
libc::closedir(dirp);
libc::closedir(dirp);
```

### double free 的通用解决方法

C 编程习惯: free 某个指针后必须把指针设为 NULL

```rust
let mut dirp = libc::opendir("/home\0".as_ptr().cast());
libc::closedir(dirp);
dirp = std::ptr::null_mut();
libc::closedir(dirp);
dirp = std::ptr::null_mut();
```

在「单线程应用」中，这种解决方法是可行的，

第一次 free 后 dirp 指针被成 NULL，第二次 free 时传入 dirp 则什么事都不会发生

因为大部分的 C/Java 函数第一行都会判断输入是否空指针 `if (ptr == null) return`

### 为什么有时 double free 没报错

有个问题困惑了我: 
- 为什么连续写几行 closedir 进程会提前 SIGABRT?
- 为什么循环中多次 closedir 进程还能正常退出?
- 为什么循环中多次 closedir 调用 `std::env::current_dir()` 时就 SIGABRT?

原因是 double free 不一定能及时被发现，可能立即让进程异常中止，也可能要等下次 malloc 时才会报错

正因为 `current_dir()` 用了 Vec 申请堆内存，内存分配器发现进程内存已经 corrupted 掉了所以中止进程

我摘抄了一些系统编程书籍对这一现象的解释:

> one reason malloc failed is the memory structures have been corrupted, When this happens, the program may not terminate immediately

感兴趣的读者可以看这本书: *Beginning Linux Programming 4th edition* 的 260 页





## 更多的内存错误调试案例

可以关注作者的 linux_commands_rewritten_in_rust 项目的 src/examples 文件夹

examples 目录下几乎都是各种内存错误的常见例子，也是作者踩过坑的各种内存 Bug

项目链接: <https://github.com/pymongo/linux_commands_rewritten_in_rust/>
