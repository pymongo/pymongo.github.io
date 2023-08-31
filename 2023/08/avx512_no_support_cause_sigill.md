# [CPU 太旧导致 SIGILL](/2023/08/avx512_no_support_cause_sigill.md)

<https://twitter.com/OnlyXuanwo/status/1696808078547828857>

我第一次遇到 四个创立 是几年在超级古老的 mac air 上面跑某区块链虚拟机，结果 SIGILL (好在我后来不用 mac 之后一直 Linux 物理机办公软件兼容问题基本就没有)

今日在推特上看到 databend 为了加速 CI 会预编译 rocksdb 结果 CI 会概率性 SIGILL 挂掉，我也跟他一样没想到原因

有网友留言说应该是 github CI 会用不同的机器，编译 rocksdb 的机器开启了 AVX512

有的 CI runner 机器没有 AVX512 指令集所以就挂掉了。涨见识了，又学习了一个 SIGILL 的案例
