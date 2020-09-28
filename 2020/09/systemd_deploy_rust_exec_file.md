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
User=centos
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

systemctl restart启动服务器后，可以通过systemctl status看到服务器启动时的STDOUT/STDERR

`curl localhost:8080`后发现，接口返回的`env::current_dir()`数据跟service配置文件的`WorkingDirectory`配置项完全一致

配置好service之后，我们Rust项目的重启脚本可以变得很简单:

```
sudo systemctl restart actix_web_basic
# Optional, check whether server restart is ok, print server start's stdout/stderr 
sudo systemctl status actix_web_basic
```

## 如何删除一个service

```
sudo systemtcl stop actix_web_basic
sudo systemctl disable actix_web_basic
# Removed symlink /etc/systemd/system/multi-user.target.wants/actix_web_basic.service.

sudo rm /etc/systemd/system/actix_web_basic.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
```
