# [top find thread](/2023/02/top_find_subprocess_or_thread_high_cpu.md)

例如一个进程有很多子进程和线程, htop 看上去使用率很高

再用 top 进去看，P 或 M 切换为 cpu 或 memory 排序，按 H 展开所有进程的子线程

最后用 c 切换线程名字和 command 的显示，找到问题的线程的 pid 之后再用 gdb attach 进去看看 backtrace 即可分析问题
