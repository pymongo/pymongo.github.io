# [ahash rustc性能对比](/2024/04/ahash_vs_rustc_hash.md)

在这篇文章末尾 [Rust 解码 Protobuf 数据比 Go 慢五倍？记一次性能调优之旅](https://mp.weixin.qq.com/s/eYWwBS979K6xFWOPM5DX-w)

作者说 ahash 比标准库快 40% 但在我的认知和之前看过的文章都说用 rustc_hash 是最快的，于是我 fork 了一份 ahash 的代码加入 rustc_hash 进行 benchmark

跑分结果是整数类型hash由于u8/u16这种ahash都用了AES指令大炮大蚊子反而更慢了，整数ahash比rustc-hash慢了2-3倍，string的hash快了1倍

我就纳闷不可能快那么多吧，再看看测试用例，把字符串长度是1024的用例删了，然后跑分结果字符串的case只比rustc快了3%

再看看README的跑分图横坐标是字符串长度，按照我的测试结果字符串长度100以内也就快2-4% 这个benchmark性能对比图真是"诈骗" 我们的业务又不会对很长的字符串进行hash，u64,u8(enum),string(32)反而是最常见的都是rustc-hash更佳不可能换成ahash
