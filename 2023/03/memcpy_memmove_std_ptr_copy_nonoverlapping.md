# [memcpy 重叠问题](/2023/03/memcpy_memmove_std_ptr_copy_nonoverlapping.md)

以前看过这样一个面试题，将一段长度为 len 连续的内存数据从 src 地址拷贝到 dst 地址

如果两段连续的地址有重叠部分怎么办(src+len>dst)

解决方法是逆序复制，从后往前复制

对应 glibc 的函数就是 memmove

memcpy 和 memmove 都是拷贝内存，区别就是 memmove 会检查两段内存是否有重叠来决定数据复制的方向

而 memcpy 则不检查(古老版本的 memcpy 会检查重叠，后来优化成性能更好的不检查，历史遗留问题)

- memcpy=std::ptr::copy
- memmove=std::ptr::copy_nonoverlapping

Reference: <https://v2ex.com/t/926553>
