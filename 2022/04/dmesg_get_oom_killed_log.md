# [dmesg log oom](/2022/04/dmesg_get_oom_killed_log.md)

今天我调试一个 rust 应用跑着跑着突然 pid 都没了，一开始以为是 panic abort 结果日志都没有，再想想是不是 coredump 结果coredump文件也没

最后试试strace去跑结果也没收到其他进程的term之类信号

最终在 dmesg 内核日志才发现原来是 oom killed 了
话说这 oom killed 还不好监控(应用跑在容器内，很多系统日志都没装)

```
sh-4.4# dmesg -T | egrep -i 'killed process'
[Wed Apr 13 11:11:47 2022] Killed process 62912 (pip) total-vm:1059884kB, anon-rss:929596kB, file-rss:4kB, shmem-rss:0kB
[Wed Apr 13 11:52:30 2022] Killed process 521741 (idp_kernel) total-vm:589920kB, anon-rss:42428kB, file-rss:1384kB, shmem-rss:0kB
[Thu Apr 21 22:21:03 2022] Killed process 213873 (idp_kernel) total-vm:17268kB, anon-rss:400kB, file-rss:3012kB, shmem-rss:0kB
[Thu Apr 21 22:21:03 2022] Killed process 206884 (java) total-vm:39361616kB, anon-rss:714760kB, file-rss:26244kB, shmem-rss:1375468kB
```

所以容器部署应用都没开 syslog/coredumpctl 如果没设置 coredump 记录则 coredump/oom 的日志都会记录在 dmesg
