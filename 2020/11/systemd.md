# [systemd部署管理项目进程](/2020/11/systemd.md)

## systemd简介

读完[阮一峰的systemd教程](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
结合我对Linux操作系统的理解，我总结下systemd的定义。

早期的Linux系统的启动一直用init.d进程，其中的d指的是daemon守护进程的意思。

所谓守护进程指的是Linux操作系统的「第一个进程(PID等于1)」，其它所有进程都是这个守护进程的子进程，所以"守护"顾名思义它要守护整个操作系统。

这里顺便提一下可执行文件的运行过程，在我 `Linux创建进程到进入Rust可执行文件的main函数的过程`
这篇文章中也有提及。

简单来说Linux操作系统PID=1的守护线程通过fork系统调用创建(克隆自身)得到一个子进程，再通过exec系统调用将可执行文件的机器码替换掉systemd的机器码。

后来由于init守护进程只能串行启动(one by one的启动其它进程)，而且init.d的启动脚本复杂，于是systemd替代掉init成为Linux的守护进程

(TODO 待验证[树莓派的Raspbian系统的autostart机制](https://www.raspberrypi.org/forums/viewtopic.php?t=18968)是不是类似systemd?autostart也能实现开机启动和管理进程?)

## systemd管理项目进程的好处

开发环境可以用ps+grep+awk找到项目进程号杀进程这种略显随意/玩具似的方法去重启/停止项目应用的后台进程，

原因是kill某个进程后可能会留下僵尸线程或僵尸子进程，[陈皓的推文中](https://twitter.com/haoel/status/1318931574591647744)
曾提到

> 程序员经常kill parent, kill child, 产生大量的zombie

用Linux系统的同学可以在`KSysGuard`应用中查看zombie进程，KDE会标注哪些进程是zombie

那么用systemd管理项目应用进程带来的好处是: 

1. systemd重启/停止进程能解决kill杀进程可能遗留僵尸进程/线程问题
2. systemd有强大的Beforce/After回调，例如让应用启动前进行docker初始化或资源分配
3. 自带日志(STDOUT/STDERR)切割/分卷(logrotate)/压缩等功能
4. 支持时间段查询、高级查询过滤条件的journalctl日志工具
5. 使用systemd内置log项目应用无需额外输出一份同样的log到某个文件中，减少日志输出到某文件的性能开销
6. 项目应用因为某些原因(例如内存不足或内存申请失败)，systemd也能自动重启应用避免网站停掉
7. docker,K8s(kubernetes)等新兴技术都用了systemd，systemd是未来运维的趋势

## journalctl日志工具的常用查询

实时滚屏显示(follow log)nginx的日志:

> journalctl -f -u nginx

查询某个时间范围内的日志(日志按日期分卷无非就是为了快速找到某天的日志):

> journalctl -u nginx --since "2018-08-30 14:10:10" --until "2019-09-02 12:05:50"

## systemd配置文件示例

以下是一个名为web_server的Rust项目应用的安装/更新systemd service的脚步示例

```bash
#!/usr/bin/bash
set -x

# check env var
if [ -z "$repo_dir" ]
then
    echo "error: env var \$repo_dir is empty!"
    echo "hints: repo_dir is a relative path"
    echo "usage: repo_dir=. bash $0"
    exit
fi

# concat from env var, get absolute path $repo_dir
declare repo_dir="$(pwd)/$repo_dir"
declare repo_dir=$(realpath $repo_dir) # normalized path string(translate all `..`)
echo "\$repo_dir=$repo_dir"

# install all services
declare -a services=("api" "message_queue")
for service in "${services[@]}"
do
sudo tee /etc/systemd/system/$service.service <<EOF >/dev/null
[Unit]
Description=$service

[Service]
WorkingDirectory=$repo_dir
ExecStart=$repo_dir/target/release/$service -f $service/config/$service.toml
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl reload $service.service # or sudo systemctl daemon-reload
sudo systemctl enable $service.service # run service after boot(其实enable就是开机启动该service的意思)
sudo systemctl status $service # sudo systemctl show $service"
done
```

配置好service之后，我们Rust项目的重启脚本两行就够了:

```
sudo systemctl restart api
sudo systemctl status api
```

!> 注意不要再重启脚本里加入编译命令，我们希望更细粒度的控制，有时候只需重启不需要编译

由于systemctl status只能看一小部分的stdout/stderr，只能大概看看启动时有没有报错，所以看log还是要用journalctl

systemd的配置文件只能用绝对路径，Rust的可执行文件的ELF信息中有动态链接库的相对路径？不过倒是不影响运行

systemd的service默认会把STDOUT和STDERR以INFO级别的日志打到journal，可以通过`[Service]`的

`StandardOutput=journal`这项配置去改

## 如何删除一个systemd service

```
sudo systemctl stop web_server
sudo systemctl disable web_server # Removed symlink /etc/systemd/system/multi-user.target.wants/web_server.service.
sudo rm /etc/systemd/system/web_server.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
```

## systectl显示memory use

`sudo vim /etc/systemd/system.conf`

> DefaultMemoryAccounting=yes

然后重新让systemctl重新加载配置文件:

systemctl daemon-reexec
