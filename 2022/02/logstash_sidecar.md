# [logstash, sidecar](2022/02/logstash_sidecar.md)

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
