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

运行效果示例:

```
Breakpoint 1, sort (a=0x555555558060 <array>, n=5) at debug4.c:21
21      /*  21  */              s = 0;
1: array[0]@5 = {{data = "bill", '\000' <repeats 4091 times>, key = 3}, {data = "neil", '\000' <repeats 4091 times>, key = 4}, {
    data = "john", '\000' <repeats 4091 times>, key = 2}, {data = "rick", '\000' <repeats 4091 times>, key = 5}, {
    data = "alex", '\000' <repeats 4091 times>, key = 1}}

Breakpoint 1, sort (a=0x555555558060 <array>, n=4) at debug4.c:21
21      /*  21  */              s = 0;
1: array[0]@5 = {{data = "bill", '\000' <repeats 4091 times>, key = 3}, {data = "john", '\000' <repeats 4091 times>, key = 2}, {
    data = "neil", '\000' <repeats 4091 times>, key = 4}, {data = "alex", '\000' <repeats 4091 times>, key = 1}, {
    data = "rick", '\000' <repeats 4091 times>, key = 5}}

Breakpoint 1, sort (a=0x555555558060 <array>, n=3) at debug4.c:21
21      /*  21  */              s = 0;
// ...
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

### patching when debugging

虽然之前同事教过我可以一边 Debug 一边加新的断点，看过 gdb 断点相关命令后我才明白其中的原理

例如发现代码 30行 的 n -= 1; 是个 Bug,可以让gdb运行到这行时 n+=1 去抵消 Bug 代码的影响

应该是运行时修改栈帧变量的数值，所以不需要重新编译

### vscode debug 界面和 gdb 的对应
- variables: `(gdb) info locals`, ...
- watch: `(gdb) watch`, `(gdb) display`
- call_stack: `(gdb) backtrace`, `(gdb) frame {n}`
- breakpoints: `(gdb) info break`, `(gdb) enable break {n}`, ...
- modules: (gdb)???
