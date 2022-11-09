# [scoop proxy](/2022/11/scoop_connect_proxy_fail.md)

最近 windows 机器的代理端口 8889 从改到 7890 了，但 scoop 工具报错了

```
Updating Scoop...
fatal: unable to access 'https://github.com/ScoopInstaller/Scoop/': Failed to connect to 127.0.0.1 port 8889: Connection refused
```

`set` 命令打印所有环境变量并没有 8889

> scoop config rm proxy

关掉 scoop 代理设置项也没用

> scoop checkup

checkup 子命令检查有哪些例如 7z 这样的核心包没装，也不管用

github 有人说是 .gitconfig 的代理设置影响了 scoop <https://github.com/ScoopInstaller/Scoop/issues/1615>
