# [systemd env file](2021/11/systemd_environment_file.md)

## 吴翱翔 systemd 系列文章

- [systemd部署管理项目进程](/2020/11/systemd.md)
- [systemd API段错误](2021/03/libsystemd_segfault.md)
- [systemd env file](2021/11/systemd_environment_file.md)

## .service 的三种配置方法

1. config file in /etc, e.g. `/etc/my.cnf`(MySQL), `/etc/grafana.ini`
2. `%i` Specifier, e.g. shadowsocks-libev@1080.service
3. EnvironmentFile and $FOO means FOO in env file

## shadowsocks-libev@1080.service

```
# shadowsocks-libev@1080.service means using /etc/shadowsocks/1080.json as config
$ cat /usr/lib/systemd/system/shadowsocks-libev@.service
ExecStart=/usr/bin/ss-local -c /etc/shadowsocks/%i.json
```

```
https://unix.stackexchange.com/questions/396978/specifier-resolution-i-and-i-difference
Thus, the behavior for the instance name /etc/path/to/some-conf is:

%i specifier with escaping: -etc-path-to-some-conf
%I specifier without escaping: /etc/path/to/some/conf
```

## prometheus-node-exporter

prometheus-node-exporter 可没有配置文件的概念，例如想改下端口只能通过命令行入参

不过观察其 service 文件发现可以用 $NODE_EXPORTER_ARGS 环境变量指定命令行入参

而 `$NODE_EXPORTER_ARGS` 的 $ 符号表示取环境变量的值，一般来自 EnvironmentFile 的环境变量文件

```
$ sudo systemctl cat prometheus-node-exporter
EnvironmentFile=-/etc/conf.d/prometheus-node-exporter
ExecStart=/usr/bin/prometheus-node-exporter $NODE_EXPORTER_ARGS
```

### 通过 systemd env file 修改 node-exporter 端口

node-exporter 默认端口是 9100，假设我想修改成 9001

```
$ cat /etc/conf.d/prometheus-node-exporter 
NODE_EXPORTER_ARGS="--web.listen-address=:9001"
$ sudo systemctl restart prometheus-node-exporter

# check prometheus port change to 9001
$ curl http://localhost:9001/metrics
```
