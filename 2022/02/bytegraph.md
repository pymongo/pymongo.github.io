# [bytegraph](/2022/02/bytegraph.md)

个人对图数据库技术好奇，基于字节在知乎专栏公开的两篇文章结合自己对 neo4j 的了解整理了一些笔记

## 术语解释

- 超级顶点/稠密点: 出入度超过 1 万的点，例如微博大 V 的粉丝

## 存储层

事务: 读取支持 read committed 的隔离级别

存储层(GS)就像是一个将磁盘的 KV 缓存到内存(page)

查询的时候存储层有缓存就直接返回，没有缓存就从磁盘的 KV store 捞出来

所以也可以将 GS 层理解成"缓存层"

写入的时候会写入一条 WAL 把数据固化到 KV store 防止数据更新的丢失

## 计算层

查询字符串 -> AST -> 优化器(RBO, CBO) -> 执行计划 -> 查询计划/执行计划缓存

后续需要理解 partition/shard 数据分区分片的逻辑，找到数据在哪个一台机器上、下推算子

merge 查询结果，最终完成查询

## meta 层?

字节的架构图中并没有像是 Tidb 的 meta 层

### Gremlin 查询语言

字节用 Gremlin 的原因看上去是对业务方学习成本低使用简单，相比之下 neo4j 的 cypher 就难多了难学

不知道以后的 GQL 标准会如何

### 优化器

主要通过两种优化器: 一种是基于规则的优化，另一种是基于代价模型优化

- 规则优化: 例如算子合并
- cost model: 基于统计信息和历史查询的代价有网络通信、计算成本、IO 成本，分析可选的查询计划森林中 cost 最低的逻辑执行计划

## 图数据分区算法

bytegraph 针对不同业务有不同分区算法。TODO

## 边存储模型

bytegraph 和费马科技 LiveGraph 等产品用的是 边表存储模型，与之对应的是一对 kv 表示一条边(边中带起点终点 id 信息)

同一个点的所有邻边都放在一个 kv 里面

优点是查询性能好只需要读一个 kv 就能获得所有边

缺点: 增删改边都要【加锁】将所有边读出来，修改后再把所有边写回去，入数性能低

如果点的邻边很多字节的优化是分裂成 B+ 树，保证每个 kv 对大小在 kb 级别数据传输的时候更均匀

边表 B+ 树的第一层是 Meta page, 第二层是 Edge page

(这个边模型还是非常复杂，一两句话的笔记都解释不清)

## bytegraph 未来要做的事

- 自研图原生存储(例如 neo4j/创邻/tiger 等产品)
- 支持尚未发布的 GQL 查询语言标准
- 支持更多 Gremlin 语言查询语法
- 异构计算: 除了 CPU 还使用 GPU / FPGA 等硬件对计算进行加速
- HTAP