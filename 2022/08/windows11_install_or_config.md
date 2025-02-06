# [win11 安装和配置](/2022/08/windows11_install_or_config.md)

为了能玩到 steam 上面更多游戏，也为了能用一些网游挂机脚本(其实就想用 ros-bot 暗黑三自动刷怪脚本)

再说我笔记本 fedora 也难用，fctix5 在 wayland 上无法设置默认用英文太恶心了

## etcher 引导盘

MSDN i tell you 移植到了一个新的站点(next), 在上面下载 business Edition 的 win11 ISO

在 Linux 下用 qBitorrent 下载磁力链接速度还不错

由于找不到 U 盘所以我献祭掉吃灰的树莓派的 SD 卡给 rpi-imager 结果制作 EFI 引导报错

我笔记本主板只能用 EFI 不能将 ISO 解压到 exFAT/FAT32/NTFS 上去引导

etcher 写入时报错，etcher 推荐我使用另一个软件制作 windows 启动盘

> yay -S woeusb-ng

## 激活

说实话 windows 激活方法很多，不需要装额外的工具，先禁用windows defender

<https://github.com/TGSAN/CMWTAT_Digital_Edition/issues/81>

> irm https://massgrave.dev/get | iex

## 驱动

刚装后声卡没有，night light 驱动也没，从 win10 开始从未用过 撸大师/360 下载驱动

直接点 win10 系统更新会自动联网下载驱动，重启后就好

## 配置

defender 终于从设置菜单里滚出去了，个性化里面也没掉了广告推荐的设置，设置少了很多精简不少

win11 的 night color 能直接一直开着，不用设置成某个时间段才能开启，能全时段开着是好评

其实我就只设置了三个地方:

- night color
- 个性化深色主题
- 关掉隐私-允许广告 ID 进行更多个性化推荐
- english display language
- xiaohe 双拼

## scoop/WSL

对开发而言，scoop + WSL + vscode(remote) 是必备的工具了

## clash 代理

用 scoop 装放进 shell:startup 或者在 WSL 装放 systemd 的 service

## switch two windows in same app

switch in-app windows (e.g. chrome switch between private windows)

- KDE: Alt+`
- macos: Cmd+`
- Windows: Ctrl+Cmd+1 (if app pin to 1st place in task bar)

autohotkey: <https://superuser.com/questions/1604626/easy-way-to-switch-between-two-windows-of-the-same-app-in-windows-10>

(不得不说 autohotkey 强大到在 mac/linux 根本没同类产品，能做到网游刷怪半自动的键盘宏)
