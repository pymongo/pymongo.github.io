# [OSTEP 笔记](/2023/08/ostep_note.md)

进程调度性能指标: 周转时间(任务完成时间-任务进入队列时间)、公平性

STCF(Shortest Time-to-Completion First)=PSJF(Preemptive Shortest Job First)，解决 SJF 因长时间任务在前面阻塞后面短时间任务执行，长时间任务执行中的时候会被短时间任务抢占

不确定的状态随机数，并发程序的形式语义

缓存亲和性，一个进程最好调度在同一个 CPU 上执行充分利用缓存，同理 K8s 节点亲和性也是想着让 pod 调度在同一个节点执行
