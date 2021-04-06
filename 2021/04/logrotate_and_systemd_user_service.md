# [logrotate和user service](/2021/04/logrotate_and_systemd_user_service.md)

需求: 用一个service每隔一秒往一个文件里打大量log，以此测试logrotate有没有按天对日志分卷和压缩

不需要开机启动或权限，所以做成user service就够了

代码比较简单，每隔一秒往log文件写入当前时间

```rust
use std::io::Write;

fn main() {
    let mut log_file = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .write(true)
        .open("./log/test_logrotate.log")
        .unwrap();
    loop {
        writeln!(log_file, "{}", chrono::Local::now()).unwrap();
        std::thread::sleep(std::time::Duration::from_secs(1));
    }
}
```

## systemd user service

systemd的user service和system service的区别就是，所有user service的操作都要加上`--user`参数而且不要sudo

不同于system service将配置放到`/etc/systemd/system`，user service的配置都会放在

> ~/.config/systemd/user/

安装user service时只能用`default.target`，不能安装成`multi-user.target`，毕竟是单用户的service

总结下systemd user service的注意事项:
1. systemctl不要sudo运行，否则缺失环境变量导致无法找到用户文件夹
2. 所有user service操作都要加上`--user`参数，例如`systemctl --user status api`
3. user service的配置都放到`~/.config/systemd/user`
4. user service只能安装到`default.target`，不能安装到`multi-user.target`

---

systemd user service的安装脚本如下:

```bash
tee $HOME/.config/systemd/user/test_logrotate.service <<EOF >/dev/null
[Unit]
Description=test_logrotate

[Service]
#Type=simple
#StandardOutput=journal
WorkingDirectory=/home/w/workspace/temp/test_logrotate/
ExecStart=/home/w/workspace/temp/test_logrotate/target/debug/test_logrotate

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user status test_logrotate

# add logrotate config
sudo tee /etc/logrotate.d/test_logrotate <<EOF >/dev/null
/home/w/workspace/temp/test_logrotate/log/*.log {
    daily
    # 只保留最近30天的日志(注意注释一定只能单独一行，不能在配置的行末加注释)
    rotate 30
    # 将日志拷贝一份进行分卷压缩，再清空原日志(类似ruby的log4r)
    copytruncate
    # 日志分割分卷时按日期命名(默认只会按xxx.1和xxx.2这样命名)
    dateext
    dateformat -%Y%m%d
    compress
}
EOF
# test log_rotate config file
sudo logrotate /etc/logrotate.d/test_logrotate 
```

注意 logrotate 配置文件的注释(#开始)不能写在行末尾，否则会解析错误

logrotate的注释只能是单独一行，不能写成`daily # comment`

```
/home/w/workspace/temp/test_logrotate/log/*.log {
    daily
    rotate 30 # 只保留最近30天的日志
    copytruncate # 将日志拷贝一份进行分卷压缩，再清空原日志(类似ruby的log4r)
    dateext # 日志分割分卷时按日期命名(默认只会按xxx.1和xxx.2这样命名)
    dateformat -%Y%m%d
    compress
}
[w@w-manjaro logrotate.d]$ logrotate /etc/logrotate.d/test_logrotate 
error: /etc/logrotate.d/test_logrotate:3 bad rotation count '30 # 只保留最近30天的日志'
error: found error in /home/w/workspace/temp/test_logrotate/log/*.log , skipping
```

配置文件写完后一定要运行一次 logrotate去检查配置文件

> sudo logrotate /etc/logrotate.d/test_logrotate 

test_logrotate的卸载脚本如下:

```bash
systemctl --user stop test_logrotate
systemctl --user disable test_logrotate
rm $HOME/.config/systemd/user/test_logrotate.service
systemctl --user daemon-reload

sudo rm /etc/logrotate.d/test_logrotate
```

`/etc/logrotate.d`内修改配置不需要重启，因为logrotate在凌晨零点crontab定时运行时才加载配置文件

比较重要就就 daily, rotate, copytruncate, dateext, compress 这几项，像redis的logrotate配置就极其简单就三行

```
[w@w-manjaro logrotate.d]$ cat /etc/logrotate.d/redis 
/var/log/redis.log {
   notifempty
   copytruncate
   missingok
}
```

## 日志分卷效果示例

```
[w@w-manjaro log]$ ls -arthl
total 4.9M
drwxr-xr-x 6 w w 4.0K Apr  1 13:30 ..
-rw-r--r-- 1 w w 999K Apr  3 00:00 test_logrotate.log-20210403.gz
-rw-r--r-- 1 w w 701K Apr  4 00:00 test_logrotate.log-20210404.gz
-rw-r--r-- 1 w w 704K Apr  5 00:00 test_logrotate.log-20210405.gz
-rw-r--r-- 1 w w 713K Apr  6 00:00 test_logrotate.log-20210406.gz
drwxr-xr-x 2 w w 4.0K Apr  6 00:00 .
-rw-r--r-- 1 w w  16M Apr  6 14:19 test_logrotate.log
```

---

参考1: [Creating a Simple Systemd User Service](https://blog.victormendonca.com/2018/05/14/creating-a-simple-systemd-user-service/)

参考2: [systemd - archlinux_wiki](https://wiki.archlinux.org/index.php/systemd#Writing_unit_files)
