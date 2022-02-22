# [clash proxy](/2022/02/clash_proxy.md)

最近用 ExpressVPN 这种基于 OpenVPN 协议的代理用的很恼火，youtube 看个公开课都卡

想起今年有 2-3 个同事/朋友推荐用的 clash 代理我还是买一个试试吧

clash 似乎是比 trojan 后出的但现在流行度貌似 clash 和 ss 居多

## clash systemd

去 *Dreamacro/clash* 的 repo 下载的可执行文件

先启动一次让它在 ～/.config/clash 生成配置文件

由于配置文件在 home 目录下所以必须用 systemd --user 的服务才能保证在用户登陆后开机启动

否则要想所有用户都开机启动将配置放在 /etc 下面

在 ~/.config/systemd/user

```
[Unit]
Description=Clash Daemon

[Service]
ExecStart=/home/w/Music/clash

[Install]
WantedBy=multi-user.target
```

## subscription

我买的是 AmyTelecom 的服务，每月限定 50 G 流量不限速，不会像蓝灯和 ExpressVPN 那样限制速度那么恶心

这个网站的设计是付费购买产品后才能完成注册，付费注册登陆后，点开 productdetails 页面

最后点击 **get subscription** 能看到很多 ss/ssr/clash 等的链接

其实这个链接就是 config.yaml 配置文件的下载链接

我将 clash 的 subscription link 输入到浏览器下载后，替换掉 ~/.config/clash/config.yaml 再 systemd --user restart clash 重启就能科学上网了
