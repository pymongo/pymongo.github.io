# [BLP读书笔记4](/2021/07/beginning_linux_programming_4.md)

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

RedHet/CentOS/OpenSUSE发行版的rpm格式二进制包分发
