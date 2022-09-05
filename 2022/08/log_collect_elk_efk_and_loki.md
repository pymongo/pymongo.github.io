# [日志收集 ELK/EFK](/2022/08/log_collect_elk_efk_and_loki.md)

本文是[《凤凰结构》可观测性章节](<http://icyfenix.cn/distribution/observability/logging.html>)
的读书笔记

## 分布式日志收集方案

Java/Spring Cloud 生态的日志收集的通用解决方案是 ELK

> ELK = ElasticSearch + Logstash + Kibana

如果部署在 K8s 上建议 Logstash 换成 CNCF 项目 Fluentd 变成 EFK

Kibana 是 ES 的 Web UI 就类似 Grafana 是 Prometheus 的可视化

App -> Filebeat(收集) -> Redis/Kafka(缓冲-削峰填谷) -> Logstash(聚合/加工) -> ElasticSearch(存储/索引)

除了 ELK/EFK 日志收集还可以用 Loki+Grafana 解决方案，由于 Grafana 项目代码用的多，我司项目只能选用 loki 方案

## Filebeat

ElasticSearch 公司发现集群每个节点的 logstash collector JVM 要吃掉 1G 堆内存，后来他们公司用 Go 重写了一个 Filebeat

ES 公司的 Beats 信息收集家族除了 Filebeat 还有用于聚合度量的 Metricbeat 等等

Logstash 可以把例如 nginx access log 这样的非结构化数据转换通过 Grok 表达式转行为结构化的 json

## 日志记录反模式

### 不打印用户敏感信息

其实这跟不记录入参的建议类似，很多项目喜欢打印接口入参的用户邮箱和 user_id

### 不记入参返回值和耗时

日志的职责是记录事件(我的理解是例如进入哪个 if 分支?)，记录入参耗时是 tracing 做的事情

追逐诊断信息可以用 BTree/Arthas (比 jdb 高级可以旁路获取运行时类各个字段值和函数入参)

这类 On The Fly 工具(其实就是 runtime 的意思区别于 compile time)

### 避免打印过多字段结构体等慢操作

如果日志内容还要查数据库或者远程调用那就别打了，或者结构体有 100+ 个字段也别打

### 避免误导别人

明明都已经 try catch 能还要 e.printStackTrace() 误导别人异常没被处理(这事我就犯过错...)

## traceId and Mapped Diagnostic Context

> TraceID 是链路追踪里的概念，类似的还有用于标识进程内调用状况的 SpanID，在 Java 程序中这些都可以用 Spring Cloud Sleuth 来自动生成

## tracing 系统的分类

追踪系统根据数据收集方式的差异可分为 log-based, service-based, sidecar-based

> Pinpoint 这种详细程度的追踪对应用系统的性能压力是相当大的，一般**仅在出错时开启**

### tracing 系统跨进程传递 span 的实现

通过 HTTP/grpc 的 HEADER 单独有个字段携带 span 信息，通过 HTTP header 进行传播

## time series db

如果 20 的节点，每个节点有 10 个微服务，每个微服务每秒生成 200 个指标，一天就有数十亿的数据传统关系型数据库难以解决

prometheus 用的时序数据库，时序数据库的特点如下

- 使用 LSM 树代替关系型数据库的 B+ 树，LSM 适合时序数据多写少读，几乎不删改
- TTL/ring_buffer/Round_Robin 数据自动轮换，例如只保留最近一年的数据
- 定时 resampling 压缩数据: 最近七天的数据精确到秒，三个月内的数据压缩成精确到天

---

> 长期趋势分析（譬如根据对磁盘增长趋势的观察判断什么时候需要扩容）、对照分析（譬如版本升级后对比新旧版本的性能、资源消耗等方面的差异）、故障分析（不仅从日志、追踪自底向上可以分析故障，高维度的度量指标也可能自顶向下寻找到问题的端倪）等分析工作，既需要度量指标的持续收集、统计，往往还需要对数据进行可视化
