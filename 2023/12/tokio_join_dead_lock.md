# [不能tokio join多个锁](/2023/12/tokio_join_dead_lock.md)

有个接口handler函数我为了想处理速度更快一些，把多个共享数据的mutex一起放在同一个tokio::join!中lock

领导批评说join上锁的顺序不确定，最忌讳上锁顺序不同导致死锁

例如两个handler同时执行，handler1先锁1等锁2，handler2先锁2等锁1，这样两次接口handler调用就能死锁了

第二个问题就是软件工程上我没有重视搭建测试环境，本地能把server运行跑起来但是连境外一些网站很卡经常timeout，所以我就频繁重启生产环境的服务端进程测试新功能页面

就一个生产服务器开了nginx端口和交易所ip白名单，应该nginx网关再开一个 xxx_test 的路径去测试，尽量解耦旁路的思路测试软件