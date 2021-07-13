# [gdb](/2021/07/gdb.md)

基于 [gdb/lldb 调试 segfault](2021/07/gdb_lldb_debug_segfault.md)

---

## print varaiable

### print $1

`(gdb) print i`: print current stack frame local var i

返回的`$1`表示将第一次print的结果存储的变量$1中: Subsequent commands will store their results as $2, $3, and so on

!> $$ is the last print output

### 「重要」gdb打印「栈上数组」

打印array数组index为1的数值:

> (gdb) print array[1]

print `array[0..5]`:

> (gdb) print array[0]@5

if print index out of range, would get `could not access memory at address` error

### 「重要」display停在断点时打印

display命令可以让程序每次停在断点时自动打印array数组:

> (gdb) display array[0]@5

info命令查看当前进入断点时会触发的display设置(有点像watch):

> (gdb) info display

---

## 「重要」打断点

用list查看某行问题代码的附近上下五行的代码

> (gdb) list 21

在 21 行打上断点

> (gdb) break 21

info列出所有已设置的断点

> (gdb) info break

当程序停在 21 行的断点时，可以通过 `continue` 命令继续

> (gdb) continue

### 「重要」command结合display达成dbg!的效果

例如我想看每次程序循环走到21行时的array数组的值，就像dbg!宏

首先我通过display命令能让程序每次停下时都打印array数组

我再通过 **command** 命令让程序到断点后执行某个命令

!> 注意: command 不加任何参数时会默认选择断点序号1

```
(gdb) command
Type commands for breakpoint(s) 1, one per line.
End with a line saying just "end".
>continue
>end
```

通过display+command发现这个冒泡排序错误示例2(错误示例1，我肉眼看出来的index out of range)

很明显的问题就是冒泡排序循环次数少了一次，最后一次应该是array[0]和array[1]的比较

### 「重要」disable命令禁用break/display

首先要用 info 看断点的序号:

```
(gdb) info break
Num     Type           Disp Enb Address            What
1       breakpoint     keep n   0x0000555555555193 in sort at debug4.c:21
        breakpoint already hit 3 times
        continue
(gdb) disable break 1
(gdb) info break
Num     Type           Disp Enb Address            What
1       breakpoint     keep n   0x0000555555555193 in sort at debug4.c:21
```

注意 disable 并不是删掉断点，只是修改断点的属性 enable -> No

类似 vscode breakpoints 面板开关某一个断点 (checkbox)

### 「重要」一边调试修改栈上数据(set variable)

虽然之前同事教过我可以一边 Debug 一边加新的断点，看过 gdb 断点相关命令后我才明白其中的原理

例如发现代码 30行 的 n -= 1; 是个 Bug,可以让gdb运行到这行时 n+=1 去抵消 Bug 代码的影响

应该是运行时修改栈帧变量的数值，所以不需要重新编译

```
(gdb) commands 2
Type commands for breakpoint(s) 2, one per line.
End with a line saying just "end".
>set variable n=n+1
>continue
>end
(gdb) run
```

虽然不能边调试边修改代码，但是可以在gdb修改栈上的n变量的值，从而「抵消掉」`n -= ` 这行 Bug 代码的影响

类似 vscode 在调试时，把 variables 面板的局部变量 n 的值改掉

但又不能像 gdb command 这样设置到达某个断点后自动改

明白了 **set variable** 命令后，以后 vscode 调试数据又多了一个新技巧——修改栈上的值

### Rust 调试时修改堆栈

用 rustc 编译时要加上 debuginfo 参数

> rustc -Cdebuginfo=2 r.rs

```
>set var n=n-1
>cont
>end
(gdb) run
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /home/w/Downloads/blp_all_sources/chapter10/r 
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".

Breakpoint 1, r::main () at r.rs:5
5               n += 2;
thread 'main' panicked at 'attempt to add with overflow', r.rs:5:9
```

gdb 的 `set var` 只能支持一些字面量的修改(数值修改)，不能进行函数调用

我的断点打在 `n+=2` 这行，可见 command 的 n=n-1 先执行再执行断点处代码 n+=2 ，导致usize往下溢出

```rust
fn main() {
    let a = [0; 3];
    let mut n = 0;
    for _ in 0..a.len() {
        n += 2;
        a[n]; 
    }
}
```

### 高级断点功能

例如 设置只触发一次的断点，例如硬件断点

---

## vscode debug 界面和 gdb 的对应
- variables: `(gdb) info locals`, ...
- watch: `(gdb) watch`, `(gdb) display`
- call_stack: `(gdb) backtrace`, `(gdb) frame {n}`
- breakpoints: `(gdb) info break`, `(gdb) enable break {n}`, ...
- modules: (gdb)???
- debug_console: lldb prompt
