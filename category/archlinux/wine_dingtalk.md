# [wine 安装/更新钉钉](/category/archlinux/wine_dingtalk.md)

aur 上 钉钉大多都是 eletron 网页版，不能用项目管理等一堆功能，而截止 2021 年 9 月 UOS(deepin 企业版)的钉钉据说还在开发中，所以只能用 wine 装钉钉和微信了

update: 由于 wine 版本的 dingtalk 太多 Bug 了各种闪退杀不干净不能发图片，我改用 dingtalk-linux(aur)

## wine初始化并安装.NET framework

> WINEPREFIX=~/.wine winecfg

如果 KDE 的 scale 设置成 200%，那么在 wine 配置的 Graphics 中将 DPI 设置成 196 * 2

deepin-wine-wechat 包的 wine 容器路径在 `WINEPREFIX=~/.deepinwine/Deepin-WeChat/`

## wine中文乱码

> yay -S ttf-ms-fonts # optional, 显示钉钉头像内的中文字体

参考: <https://www.jianshu.com/p/df2c679f0d12>

我在网上搜 msyh.ttc 就容易搜到 [下载页面](https://github.com/owent-utils/font/tree/master/%E5%BE%AE%E8%BD%AF%E9%9B%85%E9%BB%91)

注意要将字体注册表文件放到 ~/.wine/driver_c 内任意文件夹

## 安装/更新钉钉

> wine DingTalk_v6.0.5.30302.exe

## 退出钉钉

1. 任务栏右键钉钉图标退出
2. killall wineserver

## 运行钉钉

首先要保证钉钉的 wine 全部退出

- wine '/home/w/.wine/drive_c/Program Files (x86)/DingDing/DingtalkLauncher.exe'
- wine /home/w/.wine/drive_c/ProgramData/Microsoft/Windows/Start Menu/Programs/DingTalk/DingTalk.lnk
- 安装钉钉后勾选运行钉钉去运行

## 微信无法发图片

ubuntu 下可以装一个 libjpeg 等

---

## wine 玩游戏

可以参考这篇文章: https://www.addictivetips.com/ubuntu-linux-tips/play-world-of-warcraft-on-linux/

或者用 lutris (linux game platform) 自动帮忙安装一堆库

需要 wine wine-mono 

winetricks 可以帮忙清除所有游戏(不想玩之后)

玩游戏的时候「强烈建议用 wayland」

wayland 可以保证全屏游戏时依然有 night color 护眼模式
