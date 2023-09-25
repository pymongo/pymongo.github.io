# [per_cpu](/2023/09/per_cpu.md)

Rust for Linux 最大的遗憾是 C 的 per_cpu 相关宏无法使用，因为需要修改 linker

Linux 看门狗喂狗 ping 回调函数中用到了 `DEFINE_PER_CPU(bool, initialized) = false` 和 `per_cpu(initialized,cpu_num)`
[How per_cpu this_cpu_ptr() impl](https://stackoverflow.com/questions/16978959/how-are-percpu-pointers-implemented-in-the-linux-kernel)

## per_cpu 的替代方案

OSTEP 第二种 per_cpu 的实现方法，如果已经知道处理器个数，创建 static 数组，数组索引就是 smp_processor_id() `linux/smp.h`

用户态获取当前在第几个处理器的办法:
- `/proc/<pid>/task/<tid>/status`
- getcpu()

## arceos per_cpu 实现

<https://github.com/rcore-os/arceos/blob/main/crates/percpu/test_percpu.x>
