# [map并发读写panic](/2024/08/fatal_concurrent_map_read_and_map_write.md)

用 mac 的同事遇到 go panic map concurrent read/write 的报错

而且是很小概率触发，我和另一个用 x86 芯片的同事都没遇过，我猜大概率是 ARM 弱原子序导致偶发的数据竞争

<https://marabos.nl/atomics/hardware.html#arm64-weakly-ordered>
