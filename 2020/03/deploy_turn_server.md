# [部署turn服务器](/2020/03/deploy_turn_server.md)

<i class="fa fa-hashtag"></i>
turn服务器是什么

用于客户端NAT网络环境下的内网穿透、webRTC(视频通话)等，野火的P2P视频通话就是借助NAT去实现

<i class="fa fa-hashtag"></i>
安装turn服务器

> apt-get install coturn

<i class="fa fa-hashtag"></i>
允许turn服务器以service的方式进行

[参考链接](https://www.allerstorfer.at/install-coturn-on-ubuntu/)

`vi /etc/default/coturn`:

> TURNSERVER_ENABLED=1

<i class="fa fa-hashtag"></i>
设置turn服务用户名密码

`vi /etc/turnserver.conf`:

在这个文件里加一行

> user=username:password

<i class="fa fa-hashtag"></i>
启动/停止查看服务状态

> service coturn status/start/stop/restart

