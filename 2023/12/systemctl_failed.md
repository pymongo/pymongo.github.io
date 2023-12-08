# [systemctl --failed](/2023/12/systemctl_failed.md)

systemd-run 的好处是不用写 service 配置文件就能跑一个应用进程，还能像 docker run 那样限制内存

> systemd-run -u $bin --property=MemoryLimit=500M --property=WorkingDirectory=/root /root/$bin

如果要做一个类似 supervisorctl 这样的 daemon 应用，我更倾向于让更成熟的 systemd 作为 parent process 而 deamon 应用只是作为一个 systemd 的客户端的感觉

然后用强大的 journal 管理多个应用的日志等

不过 systemctl 并没有办法只列出所有 deamon 应用通过 systemd-run 创建的 transient unit 所以建议 daemon 应用给 unit 命名加一个前缀去过滤

---

我今天问 gpt 才发现 systemd 一个宝藏功能 --failed 列出所有失败(exit_code 异常)的进程

```
systemctl --failed

  UNIT                                          LOAD   ACTIVE SUB    DESCRIPTION
● run-rf863c7c3c8d8478abd8bad1c28d3e71d.service loaded failed failed /root/./test_okx

  UNIT                    LOAD   ACTIVE SUB    DESCRIPTION
● save_hedge_pair.service loaded failed failed /root/save_hedge_pair
```

毕竟没办法只列出所有 transient unit 通过 --failed 列表也能快速列出最近 systmed-run 跑的进程有没有报错异常退出

最后错误处理完后可以用 `systemctl reset-failed` 清空 failed 列表
