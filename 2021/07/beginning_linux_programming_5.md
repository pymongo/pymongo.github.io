# [BLP 读书笔记 5: 进程](/2021/07/beginning_linux_programming_5.md)

## 「重要」ch11 process and signals

### How to define a process

> an **address** space with one or **more threads executing** within that address space, and the required system **resources** for those threads

resources eg. DLLs(dylib), open_files, env_var, data_section_of_excutable_file...

### 为什么线程也有 PID? 

在 Linux 内核**源码中进程和线程是同一个结构体**，这也是为什么线程的 ID 也叫 PID

<!-- ### gettid() 和 getpid() 是一样的 -->
### **check PID is a thread or subprocess**

child process 特点:
1. gettid() 和 getpid() (在我 5900X CPU 上 fork 出来的 subprocess 确实如此)
2. 线程会出现在所属进程的 `/proc/$PID/task` 文件夹内
3. 其它线程的 Tgid(thread gourd id) 等于主线程的进程 ID 也等于主线程 ID

以下 PID=608 是 thread 的例子

```
[w@ww ~]$ ls /proc/$(pidof sddm)/task
596  608
[w@ww ~]$ cat /proc/596/status | head -n 6
Name:   sddm
Umask:  0022
State:  S (sleeping)
Tgid:   596
Ngid:   0
Pid:    596
[w@ww ~]$ cat /proc/608/status | head -n 6
Name:   QDBusConnection
Umask:  0022
State:  S (sleeping)
Tgid:   596
Ngid:   0
Pid:    608
```

以下 PID=1059133 是 process 的例子

```
Name:   get_fork_subpro
Umask:  0022
State:  S (sleeping)
Tgid:   1059080
Ngid:   0
Pid:    1059080
PPid:   977803

Name:   get_fork_subpro
Umask:  0022
State:  S (sleeping)
Tgid:   1059133
Ngid:   0
Pid:    1059133
PPid:   1059080

1059080 # ls /proc/$PID/task

1059133 # ls /proc/$PID/task
```

### ps/top STAT column

```
$ ps -ax | less
    PID TTY      STAT   TIME COMMAND
      1 ?        Ss     0:03 /sbin/init
      2 ?        S      0:00 [kthreadd]
      3 ?        I<     0:00 [rcu_gp]
```

**进程的状态**:

- S: Sleeping, usually waiting an event to occur such as a signal or input
- R: Running or Runnale(on run queue about to run)
- D: Uninterruptible Sleeping(Waiting), usually waiting for IO to complete
- T: Stopped, stopped by job control signal or under the control of a debugger
- W: Paging
- I: Idle kernel thread
- Z: Zombie(Defunct): terminated but not reaped by its parent(parent is sleeping, child is terminate, until parent call wait reaped child exit_code, child keep zombie status)
- L: Low priority task
- <: High priority task, run more often
- s: process is a session leader
- +: process is the *foreground* process group
- l: process is multithreaded

explain:
- `+(foreground)` status: process is running on CPU, on single-core CPU only one process can be foreground at a time
- multithreaded process: /proc/${PID}/task/ has more than one subdirectory

ps 列表出现频率高的几种状态: S(Sleeping), I(Idle kernel thread), <(High priority), s(session leader), l(multithreaded)

PID=1 init is all processes's ancestor

#### **multithreaded process example**

> ls /proc/$(pidof sddm)/task
> 
> 596  608

596 is sddm's process PID(main thread PID), and 608 is it's other thread PID

> ls /proc/$(pidof bluetoothd)/task
> 
> 653

### process scheduling and CPU time slice

#### preemptively multitasked

> process can't overrun their allocated time slice.
> 
> They are preemptively multitasked so that they are suspended and resumed without their cooperation
>
> on windows 3 process need yield explicitly so that others may resume

首先这里有两个不同的调度算法的概念:
1. 抢占式(linux): 优先度高的分配到更多的时间片(time slice)
2. 协作式(yield): 当前进程需要显式 yield 交出 CPU 的控制权，才能切换到其它进程工作

#### ps -axl NI column (nice value)

术语:
- hog the processor: 占用处理器
- niceness: nice/renice command, similar to priority?
- nice: run a process with modified scheduling priority
- renice: change a running process scheduling priority
- nice(2): int nice(int inc), add nice value for calling thread

§ increase priority of waiting user input process

> system increase its priority so when user input complete and it's ready to resume, 

### system API

> int system (const char *string);

same as `sh -c string`

return 127 if can't run the command, -1 if an error occur, otherwise is subprocess exit code

system("ps ax"); 会返回 

```
// ...
 932322 pts/4    S+     0:00 ./system1
 932323 pts/4    R+     0:00 ps ax
Done.
```

而 system("ps ax &"); 则会返回

```
Running ps with system
Done.
    PID TTY      STAT   TIME COMMAND                         
      1 ?        Ss     0:03 /sbin/init
// ...
 932429 pts/4    R      0:00 ps ax
```

可见加上 " &" 后父进程先打印 Done 然后退出，子进程 ps 则不管继续打印

第二个不同点是子进程 ps 状态没有 foreground

### exec syscall

替换当前进程的可执行文件，例如 PID=1 的 init 进程会先 fork 自己再用 exec 替换成其它可执行文件

注意 exec 之前要么关闭所有已经打开的文件，要么给文件加上 close on exec flag

### fork

dup current process and create a child process

fork 失败时返回 -1

子进程的 fork 返回 0, 父进程的 fork 返回子进程的 PID

```rust
fn main() {
    let mut msg = "parent process";
    let mut n_times = 1;
    println!("before fork");

    match unsafe { libc::fork() } {
        -1 => {
            unsafe {
                libc::perror("fork\0".as_ptr().cast());
                libc::exit(libc::EXIT_FAILURE);
            }
        },
        0 => {
            msg = "child process";
            n_times = 3;
        },
        child_process_pid => {
            dbg!(child_process_pid);
        }
    }

    for _ in 0..n_times {
        println!("{}", msg);
        unsafe { libc::sleep(1); }
    }
}
```

也就是从 fork 这行代码执行时就 "分裂" 成 父子两个进程去接收 fork 函数的返回值

父进程收到的是 子进程的 PID，而子进程收到的则是 0，方便后续的程序代码区分当前执行代码的进程是不是子进程

### **wait**

pid_t wait(int *stat_ret);

parent process can parse child's stat_ret by some marco in sys/wait.h

- libc::WIFEXITED(stat_ret) -> bool: child process exit normally
- libc::WEXITSTATUS(stat_ret) -> c_int: extracts child process exit code from stat (by bit mask)
- libc::WIFSIGNALED(stat_ret) -> bool: child process exit with a uncaught signal

> pid_t waitpid(pid_t pid, int *stat_loc, int options);

wait a specify PID, if pid arg is -1, it would wait any child process

waitpid 的 WHOHANG 参数表示 wait 的时候「不阻塞」父进程，可能是用来快速判断有没有子进程或子进程有没有结束?

### **zombie process**

例如父进程 sleep(10) 子进程 sleep(1) 子进程比父进程提前结束

但是父进程又有 wait 子进程结束的代码，要获取子进程的 exit_code

由于此时父进程还在 sleep ，子进程被迫僵在那不能销毁

> child still in the system because its exit code needs to be storedin case the parent subsequently calls wait

这时候子进程就处于一种 zombie process 的状态，占用系统资源但又只能干等着

```
ps -al
F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
0 S  1000  987402  879916  0  85   5 -   591 -      pts/4    00:00:00 fork2
1 Z  1000  987403  987402  0  85   5 -     0 -      pts/4    00:00:00 fork2 <defunct>
```

if zombie process's parent is terminate abnormal, then zombie process get PID=1 as it's parent

until PID=1 init cleanup, zombie waste a lot system resource

### **signal**

some signal:

if process received a signal and without caught it, process would terminate with core dump file

这些信号不处理的话进程会立即中止:
- SIGALRM: alarm clock
- SIGFPE: floating-point exception
- SIGHUP: hangup
- SIGILL: illegal instruction
- SIGINT: terminal interrupt(Ctrl+C)
- SIGKILL: kill, can't be caught or ignored
- SIGPIPE: write on a pipe without reader(pipe must has a pair of reader/writer)
- SIGQUIT: terminal quit(Ctrl+\ )
- SIGTERM: termination
- SIGTSTP: terminal (Ctrl+z)

有些信号则是暂停/恢复进程:
- SIGSTOP: stop executing, can't be caught or ignored
- SIGCHLD: child process has stopped and exited

#### raise syscall send signal

#### kill command send signal

> kill -HUP 512

kill send signal SIGHUP to PID=512

#### **reload config file by signal**

需求: 如何不重启服务进程的前提下重新加载业务的配置文件?

自定义一个信号量的处理的回调函数，一旦收到该信号立即重新读取配置文件到 RwLock 中

而不需要像 log4rs 那样轮询配置文件改动

### **signal callback/handler**

`chapter11/ctrlc1.c` 示例中第一次处理 SIGINT 信号时打印一句话，并将回调设成默认

所以要在第二次 Ctrl+C 时才能将进程中止

由于 SIGINT 处理回调是模拟硬件中断的软中断，可以了解下 arduino 硬件中断文档

参考 [arduino - attachinterrupt](https://www.arduino.cc/reference/en/language/functions/external-interrupts/attachinterrupt/)

!> 绝对不要在中断回调函数中执行耗时操作，例如涉及 IO 操作的打印，中断回调中**仅修改全局值**即可

在硬件中断中，像 delay(), micros() 之类定时器相关函数全部暂停，因此中断的处理时间越快越好，免得对定时器影响过大

建议绑定信号中断回调函数用 sigaction() 系统调用，别用过时的 signal()

signal 函数的返回值是该信号上一个回调函数，就有点像 swap_and_replace 的感觉

> last_handler = signale(SIGINT, curr_handler);

#### kill syscall send signal

由于线程也有唯一的 PID ，所以 kill 能给进程或线程发信号

一般只能给同一个 UID 的进程(同一个用户进程/线程)发信号，例如用户进程想发 SIGINT 给 root 用户的 PID=1(init) 进程是没有权限的

#### alarm syscall similar JS setTimeout

> unsigned int alarm(unsigned int seconds);

功能: 进程在 seconds 秒后给自己发一个 seconds 信号，达到类似 JavaScript 的 setTimeout 函数效果

(setTimeout 递归调用不就成了 setInterval)

返回值 -1 表示调用失败，正整数的返回值表示距离下一个 alarm 信号还有多少秒

注意同一个 PID 的进程/线程只能设置一个 alarm ，重复设置会覆盖上一个 alarm() 设置

#### pause/sigsuspend suspend process/thread wait signal

```
Using signals and suspending execution is an important part of Linux programming.

It means that a program need not necessarily run all the time.

Rather than run in a loop continually checking whetheran event has occurred, it can wait for an event to happen.
```

#### sigaction, better signal syscall

> int sigaction(int sig, const struct sigaction *act, struct sigaction *oact);

oact arg is used to store old sigaction struct which handle to sig signal

if act arg is null reset to default handler

same to signal, EINVALif may invalid arg or catch SIGKILL/SIGSTOP(uncatchable signal)

#### Ctrl+\ send SIGQUIT

if Ctrl+C SIGINT handler is change, you can use Ctrl+Q send SIGQUIT to terminate program

#### be careful data race in signal

#### SA_RESETHAND sa_flag

reset to default handler after custom_handler end

### signal mask and blocked/pending signals

<https://stackoverflow.com/questions/16041754/how-to-use-sigsuspend>

```rust
let mut sig_mask = std::mem::zeroed();
// sigfillset block all signal
libc::sigfillset(&mut sig_mask); // libc::sigemptyset(&mut sig_mask);
// only allow SIGALRM
libc::sigdelset(&mut sig_mask, libc::SIGALRM);
libc::sigsuspend(&sig_mask);
```

### **signal interrupt when systemcall**

系统调用一般会立即结束且返回 errno=EINTR

### 信号1处理函数没处理完又来了信号

硬件中断就会被信号2中断，或者信号处理函数1被信号1中断发生类似"递归调用"的效果

软中断可以有队列，所以信号可以是 pending 的，但是也可以通过 sigaction 的 flag 改变这种情况的处理行为

这段话很难读懂，先放一放

```
A signal handling function could be interrupted in the middle and called again by something else. When you come back to the first call, it’s vital that it still operates correctly. It’s not just recursive (calling itself),but re-entrant (can be entered and executed again without problems). Interrupt service routines in the kernel that deal with more than one device at a time need to be re-entrant, because a higher-priorityinterrupt might “get in” during the execution of the same code.
```
