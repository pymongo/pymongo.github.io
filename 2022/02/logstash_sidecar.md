# [logstash, sidecar](2022/02/logstash_sidecar.md)

本文随便扯点工作中学到的容器、网关、日志收集的笔记

## alpine

好处: 体积最小的 docker container 适合放 release build binary

缺点: 坑点是只能用 musl ? musl 在内存分配等方面的性能不如 glibc

## 网关

解决前端需要记 prometheus,loki 等等一堆微服务后端的地址，不仅麻烦还会跨域
(前端开发会吐槽: 还要记后端上百个微服务地址烦到心态爆炸)

针对前端需要记忆一堆随时可变的微服务地址，可以选择请求某个接口返回微服务列表，
例如 nacos 微服务注册/发现/配置服务，但仍无法解决跨域

针对跨域可以用 nginx 根据 HTTP 路由转发不同微服务端口，例如请求带 /api 前缀转发到 3000 端口
但 nginx 似乎只支持 HTTP ? 所以大伙一般也不用

我对网关调研不多貌似用 envoy 做网关用 Spring cloud gateway 也有

## 伴生/旁路(sidecar?)

k8s 的例子:
- k8s 一个 pod 可以有多个 container
- 同一个 pod 内多个 container 可共用 volume
- 主业务容器叫 app 伴生/旁路容器叫 sidecar
- app 写数据到 volume 伴生容器读 volume 收集日志/metrics 

docker/systemd 就是让应用将日志打印到 stdout 然后 docker logs/journal 去收集日志再做日志分割压缩等等操作

## 日志收集两种做法

一、每个业务模块搞一个伴生容器再汇总

二、例如 filebeat/logstash 全局日志收集

更大力度放一个，例如一个 k8s node 放一个，
每个业务模块按固定格式规范将日志放在固定路径，日志输出内容也是固定格式

## 日志和 tracing 区别

分布式 tracing 指的是例如数据库业务输入一个查询语句的 rpc 到执行结束

中间经过的多机多进程多个函数的过程，每个函数耗时等等

tracing 为了分析查询性能哪一个环节耗时很久，跟日志是两回事

所以 tracing 必然要在查询或一次 rpc 处理上下文中加入很多记时记调用的内容，导致性能会下降很多

## dind

dind aka docker in docker

常见于 gitlab CI/CD 中

## kind

kind aka kubernetes in docker (跟 dind 的缩写有点像)

kind 和 minikube 这是 TIDB 文档中介绍最简构建 k8s cluster 的方案

## gitlab SDK

有 python gitlab SDK，也可以自己根据 graphql/RESTFUL API 获取 gitlab 信息
