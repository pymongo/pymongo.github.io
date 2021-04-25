# [AWS lambda serverless](/2021/04/aws_lambda_serverless.md)

2021-04-24 的 rust_meetup_chengdu

我最喜欢 Rust 嵌入式 HAL 的分享，讲的挺生动

卡琴司机分享的 <https://github.com/uinb/galois> Rust 撮合

我学到了 broker=券商 的术语，但我质疑了 PPT 中 orderbook 用 BTreeMap 存储 peek/poll 操作的时间复杂度不是 O(1)

TODO Java/Rust 的 TreeMap 的 firstEntry 的时间复杂度

## 什么是 serverless

Aws lambda 产品就是 serverless

为了更细力度的服务器计算资源的划分

部署不用租服务器(这就是serverless的核心)，一旦用户请求来了才会 new 一个计算资源/容器/VM（lambda函数）

计算资源是按客户代码运行时才按毫秒，像数据库这种持久的就另外收费

处理请求后再毫秒级关机，qemu或docker并不能达到这种需求(毫秒级启动和关机)

要做到当用户请求客户的应用时，毫秒级别的时间就能new一个lambda函数VM去处理请求

## 类似的 serverless 产品

2020 rust_conf_shenzhen 讲述了一个 target 为wasm的单个Rust函数，例如在线图片压缩
