# [spawn or exec](/2022/04/process_spawn_or_exec.md)

Rust 子进程有 spawn 和 exec 两种启动方式

spawn 的子进程被 kill 之后会变成「defunct」状态(僵尸进程) 。用 exec 启动则子进程有点像「detach」运行，被 kill 不会变僵尸

应该是 spawn 启动方式走了 clone 系统调用有更细粒度设置导致了标准库两种进程启动方式对僵尸进程处理不同

https://twitter.com/ospopen/status/1514949414791806985

标准库进程 spawn/output 走的是 clone+exec 系统调用，我的理解是相比标准库 exec 设置了更多父子进程的相关设置，
导致二者应对子进程被 kill 而父进程依然存活的行为会不一样
