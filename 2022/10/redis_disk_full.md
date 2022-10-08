# [redis 硬盘满的报错](/2022/10/redis_disk_full.md)

遇到这样的 redis 报错

```
MISCONF: Redis is configured to save RDB snapshots, but it is currently not able to persist on disk. Commands that may modify the data set are disabled, because this instance is configured to report errors during writes if RDB snapshotting fails (stop-writes-on-bgsave-error option). Please check the Redis logs for details about the RDB error.
```

查 StackOverflow 说是 redis 将内存的数据写到硬盘 dump.rdb 的时候要么没权限要么硬盘满

```
/dev/vdc        4.8G  4.1G  743M  85% /data/middleware-data/redis
tmpfs            16G   12K   16G   1% /run/secrets/kubernetes.io/serviceaccount
```

## redis 日志存放配置

我一开始猜 redis 日志可能在 kubectl log 那边，通过 describe pod 看到 redis 日志位置

```
root@redis-0:/data/middleware-data/redis/log# tail redis-6379.log 
1:M 08 Oct 2022 02:09:57.743 * 1 changes in 3600 seconds. Saving...
1:M 08 Oct 2022 02:09:57.770 * Background saving started by pid 15749
15749:C 08 Oct 2022 02:10:19.282 # Write error saving DB on disk: No space left on device
```

或者用 redis 的 config 命令去获取日志配置

```
redis-svc:6379> config get logfile
1) "logfile"
2) "/data/middleware-data/redis/log/redis-6379.log"
```

---

pvc 扩容或者清理下硬盘，重启 redis 后总算恢复了
