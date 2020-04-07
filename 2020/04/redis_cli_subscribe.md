# [redis-cli订阅频道](/2020/04/redis_cli_subscribe.md)

理解项目的一些ruby代码时发现，不同ruby脚本/子系统之间是通过redis的频道进行消息传递

进入redis-cli之后，

订阅是 `subscribe $channelName`
 
推送消息是 `publish $channelName $message`

推送消息成功后会返回一个int，告诉收听频道者的数量

---

题外话：ruby元编程之send

send的作用是将字符串的运算符给eval了，

例如：

> 1.send ">", 2 # false
 
> 1.send "<", 2 # true 
