# [凤凰架构笔记](/2022/09/icyfenix_notes.md)

## 架构部分

K8s 集成了 Spring Cloud 中 配置中心(config map)、服务发现(K8s service 概念)、网关(ingress)、熔断、负载均衡(KubeDNS) 等虚拟化的基础设施，
可以减少非业务代码的比例

> Kubernetes 本身无法做到精细化的服务治理，包括熔断、流控、监视，等等，我们将在基于 Istio 的服务网格架构中解决这个问题

> 服务网格（Service Mesh）是目前最先进的架构风格，即通过中间人流量劫持的方式，以介乎于应用和基础设施之间的边车代理（Sidecar）来做到既让用户代码可以专注业务需求，不必关注分布式的技术

```
无服务架构原理上就决定了它对程序的启动性能十分敏感，
天生不利于 Java (除非 GraalVM 预编译)尤其是 Spring 这类启动时组装的 CDI(上下文依赖注入) 框架
```

[K8s 跟 Spring Cloud 同类功能的解决方案对比表](http://icyfenix.cn/architecture/architect-history/post-microservices.html)

## 单机数据库事务

### 基于日志实现

1. begin
2. 多个 SQL 操作写入日志
3. db 看到客户端发 commit 才开始执行
4. 全部执行成功才写一条事务完成的日志并告知客户端

### sqlite 基于影子分页(shadow paging)技术实现的弱事务

1. 拷贝所有事务要修改的数据
2. 所有要修改的数据的副本都改完后
3. 将指针从旧数据指向修改后的数据副本完成事务

### WAL

由于日志型事务需要收到全部客户端 SQL 请求才开始写硬盘，硬盘 IO 吃紧

WAl 的诞生就是一种 trade-off 尽可能来一条数据就不断写硬盘

> Write-Ahead Logging 先将何时写入变动数据，按照事务提交时点为界，划分为 FORCE 和 STEAL 两类情况

WAL 这部分比较复杂，略过。就有些 checkpoint, redo(重做日志), undo

### 隔离级别

> 让用户可以调节数据库的加锁方式，取得隔离性与吞吐量之间的平衡

1. Serializable(串行，全局互斥锁最高级别)
2. Repeatable Read(引入幻读问题)
3. Read Committed(2 的基础上还引入不可重复读问题)
4. Read Uncommitted(3 的基础上还引入脏读问题)
5. 完全不隔离(还引入 dirty write 问题，基本不讨论这种情况)

> 没有必要迷信什么乐观锁(通过 version 字段)要比悲观锁更快的说法，这纯粹看竞争的剧烈程度，如果竞争剧烈的话，乐观锁反而更慢


|隔离级别|加锁情况|幻读|不可重复读|脏读|
|---|---|---|---|---|
|可串行化 (Serializable)|写 + 读 + 范围|
|可重复读 (Repeatable Read)|写 + 读|Y|
|读已提交 (Read Committed)|写 + 间断的读|Y|Y|
|读未提交 (Read Uncommitted)|写|Y|Y|Y|

假设并发的两个事务分别是 A 和 B

- 幻读：A 的两次一样的区间查询得到不同的结果，因为两次之间刚好 B 在该区间插入了记录；
- 不可重复读：A 的两次一样的记录查询得到不同的结果，因为两次之间刚好 B 修改了该条记录；
- 脏读：A 读到了 B 修改但未提交的数据，且 B 最后放弃了该数据的提交。

## data 是复数形式

[postgres 源码中大量可见的 Datum 其实是 data 的单数形式](https://twitter.com/yihong0618/status/1565576175803854848)

## 分布式事务

人们把使用 ACID 的事务称为“刚性事务”，而把笔者下面将要介绍几种分布式事务的常见做法统称为“柔性事务”

柔性事务只保证最终一致性，CAP 理论中牺牲了 C 来达到比较好的性能

## HTTP

### HTTP Cache Header

Cache-Control: max-age=600 其实是浏览器客户端的缓存，请求 url 600s 内重复发就直接返回浏览器自身的缓存

### 减少连接数

CSS 雪碧图多个小图拼在一起减少请求，但是有时候会是反模式，例如只要其中一个图也需要下载完整的雪碧图

由于 HTTP 1.1 无法区分服务端返回的多个响应分别属于哪个请求，因此 HTTP 2.0 的最小单位不再是一个请求而是一个 Frame

每个 Frame 都告诉属于哪一个 stream_id 这样就实现了一个 TCP 连接多路复用

在 HTTP 2.0 这时候再去做雪碧图或者减少请求都没必要了

可能有前端说 HTTP 请求的 header 太多可能比 body 都大，但是图片等静态资源本身就是占比较低的(占比高的是 XHR)

但也因为所有大文件传输复用一个 TCP 导致 `HTTP/2 未能解决传输大文件慢的根本原因`

### On-The-Fly Compression

古老时候服务端还需要一份资源同时存 gzip 压缩过的和未压缩的，根据客户端 Header 返回哪个

但现在的 Web 框架都是流式的 即时压缩。一边压缩一边返回不必等压缩成功在返回，缺点是 Content-Length 字段就无法给出了

> HTTP/1.1 通过分块传输解决了即时压缩与持久连接并存的问题，到了 HTTP/2，由于多路复用和单域名单连接的设计，已经无须再刻意去提持久链接机制了，但数据压缩仍然有节约传输带宽的重要价值

### QUIC: HTTP over UDP

QUIC(Quick UDP Internet Connections) 是一个谷歌推动的下一代网络传输解决方案

例如 Rust/Python 社区大佬 djc 参与了 Rust 的实现

> IETF 正式批准了 HTTP over QUIC 使用 HTTP/3 的版本号，将其确立为最新一代的互联网标准

### CDN

CDN 缓存的管理就不存在通用的准则。

现在，最常见的做法是超时被动失效与手工主动失效相结合。超时失效是指给予缓存资源一定的生存期，超过了生存期就在下次请求时重新被动回源一次。而手工失效是指 CDN 服务商一般会提供给程序调用来失效缓存的接口，在网站更新时，由持续集成的流水线自动调用该接口来实现缓存更新，譬如“icyfenix.cn”就是依靠 Travis-CI 的持续集成服务来触发 CDN 失效和重新预热的。

## Linux Virtual Server

负载均衡根据 OSI 七层模型主要可分为两类: TCP 之下的改改请求包的 src/dst ip(LVS) 或者 TCP 之上的 nginx

load balancing software for Linux kernel–based operating systems

## redis and etcd

- redis: AP, 不保证强一致性
- etcd: CP, 强一致性但吞吐量低只适合存储元信息

## 布隆过滤器

> 布隆过滤器是用最小的代价来判断某个元素是否存在于某个集合的办法

布隆过滤器常见于缓存的索引

## cookie session

由于 cookie 明文传输不安全，因此服务端 Set-Cookie 只会返回给客户端一个 key

然后下次客户端请求带着这个 key 服务端去内存找该客户端状态的 value

这样服务端 kv 存储多个客户端状态且 cookie 只传 key 的技术叫 cookie session

> Cookie-Session 方案的另一大优点是服务端有主动的状态管理能力，譬如很轻易就能实现强制某用户下线的这样功能

## 分布式的 cookie session

- 牺牲一致性(C): 让均衡器保证某个前端一定只会调度到某个节点，缺点是该节点故障后永久丢失部分数据
- 牺牲可用性(A): Session 之间组播复制的同步代价高昂，节点越多时，同步成本越高，缺点是数据同步成本极高
- 牺牲分区容忍(P): 所有 session 都放一个节点上单点，其他服务节点来访问，缺点是该节点故障后所有服务不可用

JWT 只是 Cookie-Session 在认证授权问题上的替代品，而不能说 JWT 要比 Cookie-Session 更加先进，更不可能全面取代 Cookie-Session 机制

## oauth/JWT 非对称加密

JWT = header(加密算法)+payload+secret

JWT 默认的 HMAC SHA256 算法需要每个服务都请求一次【授权服务器】验证签名

集群仅授权服务器单点持有私钥

> 公钥不能用来签名，但是能被其他服务用于验证签名是否由私钥所签发的。这样其他服务器也能不依赖授权服务器、无须远程通信即可独立判断 JWT 令牌中的信息的真伪

## JWT 优缺点

重启后，客户端仍然能毫无感知地继续操作流程；而对于有状态的系统，就必须通过重新登录、进行前置业务操作来为服务端重建状态。尽管大型系统中只使用 JWT 来维护上下文状态，服务端完全不持有状态是不太现实的，不过将热点的服务单独抽离出来做成无状态，仍是一种有效提升系统吞吐能力的架构技巧

JWT 缺点:
- 服务端无法主动失效 token， 缓解办法服务端维护 JWT 失效黑名单
- 重放攻击，缓解办法在信道层面上 HTTPS 解决
- nginx HTTP Header 默认上限 4kb
- 客户端存储 JWT 用 localStorage？Indexed DB？它们都有泄漏的可能
- 无状态不能实现在线用户实时统计等需求

## isto AuthorizationPolicy CRD

isto 用于授权控制的 CRD

## kernel namespace 的八大资源隔离

- mount: 功能上大致类比 chroot
- UTS: 隔离 hostname
- IPC
- PID
- Network
- User
- Cgroup
- Time: 隔离系统时间(5.6+)

## 没有被 namespace 隔离的
- syslog

## K8s Federation

> 集群联邦（Federation）：对应于多个集群，通过联邦可以统一管理多个 Kubernetes 集群，联邦的一种常见应用是支持跨可用区域多活、跨地域容灾的需求。

K8s 元数据文件中 spec 字段所描述的便是资源的期望状态

## K8s HPA
Horizontal Pod Autoscaling

## K8s StatefulSet

> 与普通 ReplicaSet 中的 Pod 相比，由 StatefulSet 管理的 Pod 具备以下几项额外特性

- Pod 会按顺序创建和按顺序销毁
- Pod 具有稳定的网络名称: (似乎就是没有 pod template hash, replica hash 之类的随机数)
- Pod 具有稳定的持久化存储

一些有状态的应用用 StatefulSet resource type

```
$ kubectl get StatefulSet -A
NAMESPACE     NAME                   READY   AGE
idp           loki                   1/1     7d18h
idp           redis                  1/1     78d
kube-system   csi-udisk-controller   1/1     253d
kube-system   csi-ufile-controller   1/1     253d
monitoring    alertmanager-main      3/3     190d
monitoring    prometheus-k8s         2/2     190d
nightly       loki                   1/1     14h
nightly       redis                  1/1     14h
test          loki                   1/1     14d
test          redis                  1/1     28d
```

但 StatefulSet 无法实现 ES 集群应用的 `备份恢复数据、创建删除索引、调整平衡策略等操作` 等功能，这时候就需要 operator 了

---

## 虚拟网卡

### brctl

主流的虚拟网卡方案有 tun/tap 和 veth 两种

tun/tap 主要用于 VPN 应用的网络流量都会过一道 VPN 虚拟网卡设备所以性能开销不小

veth 实际上是一对设备，多个 docker container 就需要一个中心化的交换机(switch), brctl 命令创建/管理虚拟交换机

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
br-eb4bf14c743d         8000.0242b1128d30       no              vetheae71f1
docker0         8000.0242e5194441       no              vethee77ab5
docker_gwbridge         8000.02425b38cc0a       no              veth5b662a4
```

### 水晶头线序

- 直连线序: Ethernet Cable Straight-Through
- 交叉线序: RJ45 cable crossorder

同类设备互连例如网卡-网卡需要交叉线序，反正例如网卡-交换机用直线线序

现在网络设备都会自动线序翻译，没有那么严格的要求了

> 同种设备用交叉线，异种设备用直连线

### 两层转发和三层转发

- 两层转发: src/dst 在同一个 IP 网段
- 三层转发: src/dst 跨网段

### Overlay 虚拟网络

优点: 可跨主机通信，缺点是额外的报文头多达 50+ byte

---

## PV and PVC

Volume 不一定是持久化的，只需要比容器生命周期长就行了，

K8s PV 是运维负责维护的(provisioned by an administrator)，研发根据自己应用对存储的需求，K8s 自动撮合匹配到合适的 PV

### PV accessModes

- ReadWriteOnce: 只能被一个节点读写
- ReadOnlyMany: 多个节点只读
- ReadWriteMany: 多个节点读写

### StorageClass

不需要运维人工分配 PV, 动态存储分配（Dynamic Provisioning）的解决方案，自动在存储资源池创建分配研发需要的 PV

## K8s 资源调度

### K8s Mi 和 M 单位区别

Mi = 1024*1024 bytes
M = 1000*1000 bytes

### Compressible Resources

可压缩资源例如 CPU core，CPU 负载高只会让 pod 变得饥饿运行变慢，不会像内存用完一样出现 OOM

> 逻辑处理器个数

- 多核处理器的一个核心
- 处理器核心里的一条 hyper-threading
- 云主机上一个虚拟化处理器

### request and limit

request 是用户/研发对资源的需求，而 limit 才是真正传递给 cgroup 进行资源限制的参数

所以 request >= limit

> requests是给调度器用的，Kubernetes 选择哪个节点运行 Pod

### 驱逐和质量等级

质量等级越低的 pod 资源不足的时候优先被驱逐

1. BestEffort: request/limit 都没设置质量等级最低
2. Burstable: 只设置了 request
3. Guaranteed: request==limit

- 软驱逐: 例如应用内存占用超 10%，列入观察期，如果只是服务抖动过一会降下去就不驱逐，如果连续几分钟超 10% 内存就驱逐
- 硬驱逐: 例如内存超 20% 是软驱逐阈值的两倍就直接驱逐掉
- graceful 驱逐

默认情况下 Kubernetes 会设置 Master 节点不允许被调度，这就是通过在 Master 中施加污点来避免的

### PriorityClass

质量等级相同的 pod 可人工设置优先级

由于 Preemption 机制优先级高的 pod 优先被调度，后面优先级低下的 pod 可能就没资源而 pending
