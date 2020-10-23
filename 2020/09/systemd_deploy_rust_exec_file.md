# [systemd部署/重启Rust项目](/2020/09/systemd_deploy_rust_exec_file.md)

部署完Rust项目后(也就是可执行文件更新后)，玩具式的方法是通过`ps -ef | grep my_app`或`lsof -i:8080`去杀掉进程再启动，但是容易报错ps -ef没找到进程之类的错误

以actix-web的HelloWorld的Example为例讲解，如何用更可靠不会报错的systemd/systemctl的service的方式去重启服务器

稍微修改下actix_web首页接口的返回值，方便打印出服务器启动后的PWD环境变量


```rust
#[get("/")]
async fn get_index() -> String {
    std::env::current_dir().unwrap().to_str().unwrap().to_string()
}
```

以下是`/etc/systemd/system/actix_web_basic.service`的service简单版配置文件，没有设置文件句柄数限制

```
[Unit]
Description=actix_web_basic

[Service]
Environment="DATABASE_URL=sqlite://db.sqlite"
WorkingDirectory=/home/centos/actix-web
ExecStart=/home/centos/actix-web/target/debug/examples/basic

[Install]
# Run service on every user startup/login
WantedBy=multi-user.target
```

每次修改了service配置文件后，都需要deamon-reload

```
sudo systemctl daemon-reload
sudo systemctl enable actix_web_basic.service
# Created symlink from /etc/systemd/system/multi-user.target.wants/actix_web_basic.service to /etc/systemd/system/actix_web_basic.service.
```

然后可以在enable services列表中看到我们创建的actix_web_basic

> systemctl list-unit-files | grep enabled

systemctl restart启动服务器后，可以通过systemctl status看到服务器启动时的stdout/stderr

`curl localhost:8080`后发现，接口返回的`env::current_dir()`数据跟service配置文件的`WorkingDirectory`配置项完全一致

配置好service之后，我们Rust项目的重启脚本可以变得很简单:

```
sudo systemctl restart actix_web_basic
# Optional, check whether server restart is ok, print server start's stdout/stderr 
sudo systemctl status actix_web_basic
```

由于systemctl status只能看一小部分的stdout，所以最佳实践还是不往stdout里写任何内容，将全部日志写到一个log文件上

## 如何删除一个service

```
sudo systemtcl stop actix_web_basic
sudo systemctl disable actix_web_basic
# Removed symlink /etc/systemd/system/multi-user.target.wants/actix_web_basic.service.

sudo rm /etc/systemd/system/actix_web_basic.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
```

## 可执行文件有dynamically linked导致service无法启动

```
● matcher.service - matcher
   Loaded: loaded (/etc/systemd/system/matcher.service; enabled; vendor preset: enabled)
   Active: inactive (dead)

9月 29 09:56:24 my_server systemd[1]: /etc/systemd/system/matcher.service:9: Executable path is not absolute: cargo build --release
9月 29 09:58:44 my_server systemd[1]: /etc/systemd/system/matcher.service:9: Executable path is not absolute: ~/.cargo/bin/cargo build --release
9月 29 09:58:44 my_server systemd[1]: /etc/systemd/system/matcher.service:9: Executable path is not absolute: ~/.cargo/bin/cargo build --release
```

因为systemd配置文件的所有二进制文件只能用「绝对路径」，而可执行文件头部信息的cargo是基于$HOME的相对路径，有两种解决思路:

一是加上环境变量`RUSTFLAGS="-C target-feature=+crt-static"`强制rustc编译时使用静态链接库

二是在.cargo/config.toml中加上配置

```
[target.x86_64-unknown-linux-gnu]
rustflags = ["-C", "target-feature=+crt-static"]
```

但是Debug后发现，并不是systemd的问题，而是service配置文件修改后不生效，即便我删掉第9行，还是提示第9行报错

原来是systemctl status命令的stdout没更新，其实配置文件是没问题的

## systemctl status启用CPU/Memory的使用率

vim /etc/systemd/system.conf

> DefaultMemoryAccounting=yes

然后重新让systemctl重新加载配置文件:

systemctl daemon-reexec

## systemd service消除zombile thread/process

以前玩具式的做法kill parent, kill child, 容易产生大量的zombie thread/process
