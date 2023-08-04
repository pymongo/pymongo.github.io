# [布隆过滤器 缓存击穿](/2023/08/bloom_filter_solve_cache_penetration.md)

## cache breakdown/penetration
【缓存击穿】指的是热点数据缓存过时失效或者例如查询 id=-1 这样不存在的 Key 导致 redis 没有起到缓存读请求的作用，解决办法是布隆过滤器，对于 id=-1 这样恶意请求可以往 redis 写一个空的记录

## 复习 HashMap 内存布局
HashSet 代码上就是一个值为空的 HashMap

内存中有个 entry 链表数组，如果发生哈希碰撞多个 key hash 到数组中的同一个 index 则新元素插入到链表头部，然后也把 key 存进 value 内

例如 entry 链表数组一开始长度只有 10 然后 key=10,index=10%10=0 和 key=100 都存进了 index=0 内，
当我获取 key=100 时就会遍历链表数组中 index=0 的链表去找到链表中 key=100 的节点

如果哈希碰撞过多或者哈希表元素过多，则 entry 链表数组就会扩容并 rehash

### bloom filter is HashSet?
使用位数组和多个哈希函数实现，有一定的误判率，适用于对查询性能要求较高且可以容忍一定误判率的场景

【bitarray】 就是为了节约空间一个 bit 表示一个 bool 达成 `Vec<bool>` 的效果，例如 C++ std::bitset 和 Rust bitvec

因为布隆过滤器追求快和节约空间，所以没有哈希表那样遇到冲突用链表存储所有冲突数值，

所以布隆过滤器每次 insert 都用多个哈希函数哈希一遍写入 bitset 去避免冲突，但是这样也会引入大量误判，例如 key=10 被 3 个哈希函数分别哈希到 0,1,2 接下来遇到 key=2 万一也是哈希到 2,1,0 就误判了

布隆过滤器判断 contains 也是所有哈希函数哈希出的 index 都存在的时候就会返回 true

## cache avalanche
【缓存雪崩】大量热点数据在同一时间过期，导致读请求大量涌入数据库负载过高，解决方法是热点数据永不过期或【随机过期时间】让数据的过期淘汰更均匀不会出现短时间大量数据过期

## redis 缓存持久化
- RDB(redis database): 定时 fork 子进程，子进程将数据写到临时文件，最后替换旧的 rdb 文件
- AOF: 所有写操作都提前写到日志文件类似 WAL 当故障重启时挨个执行 AOF 中未执行的语句
