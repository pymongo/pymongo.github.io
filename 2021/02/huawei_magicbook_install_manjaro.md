# [华为笔记本安装manjaro系统](/2021/02/huawei_magicbook_install_manjaro.md)

首先华为magicbook的BIOS仅支持UEFI的FAT文件系统的引导，所以将安装包ISO直接解压到FAT文件系统的U盘是不行的.

推荐使用etcher或raspberry_imager这两个工具来制作U盘启动盘

## KDE or GNOME?

首先我尝试的是xfce_minimal版本，装完后由于显卡驱动或xorg_server故障不仅不能改亮度，而且重启或开机大概率直接黑屏，

让我一度怀疑是引导的问题，后来在cli环境改了亮度后，再重启就100%黑屏，但是能先看到grub菜单，说明引导是没问题的。

后来经网友提醒黑屏时按<var class="mark">CTRL+ALT+F2</var>可以进入cli模式，后来有个10年arch_linux经验的指点调试发现xstart启动报错。

而且xfce的设置选项太少了，还不支持搜索，于是我打算将桌面换成跟10年arch同事一样的KDE/plasma桌面。

GNOME的设置不集中，除了settings还有GNOME tweak，而KDE的manjaro设置菜单有nightshift, brightness, ui_scale, dark_mode等我密切需要的display/monitor相关设置。

## Linux桌面常用快捷键

Alt+F2: 弹出搜索框，功能类似mac的spotlight_search

Ctrl+Alt+F1/F2: 似乎是切换recovery模式或启动模式的按键，对于桌面版Linux来说Ctrl+Alt+F1切换成图形界面，那么F2就是cli_mode/text_mode

manjaro/arch里text_mode和desktop_mode互相切换还是挺容易的，Ubuntu则稍微麻烦点

## manjaro安装gcc和rust

建议先更新glibc，否则gcc安装后会提示glibc版本太低，但是更新glibc会同时更新gtk,KDE等，可能在安装KDE的更新时图形界面会没掉然后黑屏，切换到cli模式再sudo reboot即可

```
sudo pacman -Su glibc # 更新glibc
sudo pacman -S gcc # 安装gcc/g++, binutils等build_tools
```

由于arch上面的软件包版本都很新，如果不想影响系统的glibc依赖组件，可以拉源码自行安装gcc

通过包管理pacman安装的rustup和rustup.rs的rustup安装脚本的区别在于

1. cargo/rustup的路径在/usr/bin，rust-analyzer的路径还在~/.cargo/bin
2. pacman的rustup不能self update，需要pacman进行更新

