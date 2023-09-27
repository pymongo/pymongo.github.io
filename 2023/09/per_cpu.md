# [per_cpu](/2023/09/per_cpu.md)

Rust for Linux 最大的遗憾是 C 的 per_cpu 相关宏无法使用，因为需要修改 linker

Linux 看门狗喂狗 ping 回调函数中用到了 `DEFINE_PER_CPU(bool, initialized) = false` 和 `per_cpu(initialized,cpu_num)`
[How per_cpu this_cpu_ptr() impl](https://stackoverflow.com/questions/16978959/how-are-percpu-pointers-implemented-in-the-linux-kernel)

## per_cpu 的替代方案

OSTEP 第二种 per_cpu 的实现方法，如果已经知道处理器个数，创建 static 数组，数组索引就是 smp_processor_id() `linux/smp.h`

用户态获取当前在第几个处理器的办法:
- `/proc/<pid>/task/<tid>/status`
- getcpu()

### Linux 内核没有 get_nprocs()

```
一种方法是通过查看内核中的cpu_possible_map变量来获取处理器的数量。cpu_possible_map是一个位图，表示系统中可能存在的处理器编号。可以使用cpumask_weight函数来计算处理器位图中被置位的位数，从而获取处理器的数量。

另一种方法是通过遍历系统中的处理器拓扑结构来获取处理器的数量。内核中的cpu_possible数组保存了系统中拥有的所有处理器，可以通过遍历该数组来计数处理器的数量。
```

还有一种办法，我看了别人的代码实现

> #define NR_CPUS		CONFIG_NR_CPUS

```
arch/ia64/kernel/setup.c

#ifdef CONFIG_SMP
unsigned long __per_cpu_offset[NR_CPUS];
EXPORT_SYMBOL(__per_cpu_offset);
```

用 CONFIG_NR_CPUS 这个值也能获取

## arceos per_cpu 实现

<https://github.com/rcore-os/arceos/blob/main/crates/percpu/test_percpu.x>
