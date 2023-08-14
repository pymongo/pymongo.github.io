# [Device Tree Blob](/2023/08/device_tree_blob.md)

在 arceos 源码中频繁提到 dtb pointer

在 rcore 教程评论区有人问，如何确定硬件的时钟频率，我们知道硬件上有多个晶振输出不同时钟频率

qemu-system-riscv64 -machine virt,dumpdtb=dump.dtb

qemu dumpdtb 之后用 device tree compile 去看 dtc dump.dtb
