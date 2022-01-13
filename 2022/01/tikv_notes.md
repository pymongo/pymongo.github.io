# [tikv notes](2022/01/tikv_notes.md)

之前我看了 tikv prometheus,cgroup,test_utils 模块的源码，抽空继续看了些 tikv 源码解释的文章

- 三篇文章了解 TiDB 技术内幕： 说存储、说计算、谈调度
- TiKv 源码阅读系列 14-16 (coprocessor/下推)
- TiKv 源码阅读系列 5: fail-rs

## 术语
- Acyclic Graph: 无环图
- DAG: 有向无环图
- RPN: 逆波兰表示法

## 分片

nebula/mongodb/arangodb 用的是对 key 做 hash 得到 shard_id 的分片策略(只不过 nebula 把 shard 叫 partition)，
而 tidb 用的是一段连续的 kv 组成一个 region

存储容量水平扩展: tidb 增加新的存储节点的时候，会重新自动均摊所有 region 使得 region 均匀分布在所有存储节点上

## 副本
replica 都是以 shard 为最小单位的，一个 shard 的多个 replica 构成 raft group

Replica 之间可能会通过 Snapshot 同步数据

## 下推存储层的算子执行模型

- 火山模型: 有个 executor 的迭代器不断 next，一次只能处理一行数据，tidb 高版本已经放弃火山模型
- 向量模型: 像列存？一次批量处理多行数据
