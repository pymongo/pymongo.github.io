# [选用下载量最高的库](/2022/08/crate_sort_by_downloads.md)

工作业务上遇到要 GBK 解码，我推荐 encoding-rs, 同事看不懂示例代码选用另一个 encoding

想起最近飞书群说 Rust 同类库不要看 github stars 数，用 star 最多的不是一个主要衡量指标

lib.rs 的同类库排名算法就比 crates.io 优秀所以很多人用 lib.rs 搜库

这是我认为的 lib.rs 库搜索排名权重

1. 下载量
2. 被其它 crate 引用次数
3. github 更新/维护频繁程度
4. github stars 数

所以 Rust 生态选用库一定要选下载量和引用次数最多的同类库
