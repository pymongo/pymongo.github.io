# redis技术积累

### AUTH(输入密码)

redis连接默认不需要密码，只要知道端口号就能连上，相比MySQL安全性较差

就算加了密码其实也能连上，只不过不能执行任何命令(除了AUTH)

AUTH命令连续输出几次密码就会强行断开连接

## SELECT(切换数据库)

redis_url中斜杠后面的数字表示db_index默认情况下redis连接的是0号数据库

例如`redis-cli -u 127.0.0.1:6379/1`连接的是1号数据库

像async-redis这样的redis库用的是标准socketAddress，所以url中不能带斜杠

只能在连上redis之后发送SELECT命令更换数据库，类型MySQL的use xxx

### MONITOR(类似打log)

redis不像关系型数据库那样有log，所以需要monitor这样的命令去监控当前数据库执行的redis命令

当redis频繁使用时，想用monitor去Debug时滚屏非常快，完全没法找到想看的redis命令

如何<var class="mark">过滤</var>monitor的输出内容:

> redis-cli monitor | grep -iE 'SET'

通过管道加 grep -iE '关键词' 能过滤monitor的滚屏内容，只保留想要看到的部分

### redis队列?

k线数据在redis中是通过一种类似队列或者叫list的数据结构去存储

## CLUSTER(集群)

TODO

### KEYS *

列出当前db的所有key

### SET/GET/DEL ${key}

设置/获取/删除 键值对