# [nebula graph](/2021/08/nebula_graph.md)

## 分布式架构

nebular_graph 跟 datafuse, TIDB 一样:

注 1: TIDB 的 meta 叫做 Placement Driver 但功能也是类似的

注 2: 一般的数据库存储层对接的是 Linux 系统，而 datafuse 对接的是 S3

- meta: 存储数据库用户信息、权限、表 schema，相当于整个分布式的中枢原子性的分配 id 给 compute 和 store
- computing: 无状态的 SQL 解析成，生成执行计划，再去存储层查数据
- storage: 分片存储，多副本(replication)多 shard

## Graph

- 点或边的结构体类型信息: label
- 边的 schema(SRC_ID,DST_ID,)

### vertex

tag/schema: 顶点的结构体字段信息

### Edge

label: 顶点或边的类型

all edge in nebula is directed, edge=src/dest+schema

edgetype/schema: 边的结构体字段信息

### 度

入度/出度/跳 也就是图的几阶邻居

## Storage(有状态)

由于顶点可能很多，所以可能分多个机器去存储(partition)，Raft 协议进行多节点 KV 同步 leader/follower 架构

- API 层: 将图数据库操作转换成 partition 和 KV 存储操作
- consensus(一致性): Raft
- 存储层: rocksdb

## Meta service(有状态)

类似 clickhouse/tensorbase 都是将 meta/data 分成两个文件夹去存储，在图数据库中这两会是不同的可执行文件分开部署

- user privilege
- schema operation
- cluster administration
- manage TTL data

## Query Engine(计算层无状态)

也叫 graphd 查询节点(集群)

1. cypher GQL -> lexer(flex) -> TokenStream
2. TokenStream -> parser(bison) -> AST(如果有缓存直接到第五步)
3. Execution Planner 
4. optimizer
5. 执行引擎: 通过 MetaService 获取点边的 schema, 再通过存储引擎获取点边数据

### Session Manager

auth 成功后会返回给客户端一个 session_id，此外 session 还会记录一些配置信息
