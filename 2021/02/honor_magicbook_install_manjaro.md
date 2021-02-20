# [荣耀magicbook安装linux系统](/2021/02/honor_magicbook_install_manjaro.md)

首先华为magicbook的BIOS不支持MBR引导，所以将安装包ISO直接解压到FAT文件系统的U盘是不行的.

推荐使用etcher或raspberry_imager这两个工具来制作U盘启动盘

## 吐槽xfce

由于以前玩过Ubuntu了，想换arch linux试试，首先我尝试的是manjaro_xfce_minimal版本。

装完后由于显卡驱动故障不能改亮度，而且重启或开机大概率直接黑屏，

让我一度怀疑是引导的问题，后来在cli环境改了亮度后，再重启就100%黑屏，但是能先看到grub菜单，说明引导是没问题的。

后来经网友提醒黑屏时按<var class="mark">CTRL+ALT+F2</var>可以进入cli/text模式，cli模式下发现xstart启动报错导致桌面没启动起来。

显卡驱动坏了也不能用功能键改亮度(可以在命令行改brightness文件的值)，连触控板驱动也是坏的

xfce的文件浏览器居然不支持new tab，都2021年了还跟windows那个file explorer一样不支持new tab(KDE/GNOME/mac都支持)

而且xfce的设置选项太少了，还不支持搜索，于是我打算将桌面换成跟10年arch同事一样的KDE/plasma桌面。

## KDE or GNOME?

我第一次安装manjaro选的xfce_minimal宣告失败，显卡驱动和触控板驱动坏的，也没有nightshift。

GNOME的设置不集中，除了settings还有GNOME tweak，而KDE的manjaro设置菜单有nightshift, brightness, ui_scale, dark_mode等我密切需要的display/monitor相关设置。

我指望manjaro完整版相比min版本能多安装gcc，实际上没有，完整版的安装过程只是多了是否安装Office的选项，

为了偶尔能阅读网络上的一些PPT,word,excel资料我还是选择安装了office。

---

以下是manjaro安装后我的一些个人设置

---

## KDE显示相关设置

KDE的屏幕亮度可以用笔记本功能键或改brightness或任务栏右下角的battery_and_brightness

nightshfit(色温)在display_and_monitor里，然后关掉长时间不用电脑屏幕变暗的设定

吐槽下KDE并不会像win10一样动动鼠标屏幕就恢复成原来亮度，一旦待机过久屏幕变暗只能手动把亮度调回去，不像win10从待机恢复时亮度也会恢复

dark_mode要把Appearance->Theme改成BreeezeDark，还要把application_style->gnome/gtk_application_style的theme改成dark

## manjaro安装gcc和rust

建议先更新glibc，否则gcc安装后会提示glibc版本太低，但是更新glibc会同时更新gtk,KDE等，可能在安装KDE的更新时图形界面会没掉然后黑屏，切换到cli模式再sudo reboot即可

```
sudo pacman -Su glibc # 更新glibc
sudo pacman -S binutils gcc make cmake # 安装gcc/g++, binutils等build_tools
```

由于arch上面的软件包版本都很新，如果不想影响系统的glibc依赖组件，可以拉源码自行安装gcc

通过包管理pacman安装的rustup和rustup.rs的rustup安装脚本的区别在于

1. cargo/rustup的路径在/usr/bin，rust-analyzer的路径还在~/.cargo/bin
2. pacman的rustup不能self update，需要pacman进行更新

## manjaro卸载steam

我用Linux又不玩游戏，manjaro KDE完整版内置了steam我不能接受，不小心点开steam又继续下载安装一堆垃圾

```
sudo pacman -Rns steam-manjaro
cd ~ && rm -rf .steam .steampath .steampid 
rm -rf ~/.local/share/Steam`````
```

## manjaro安装chrome

```
sudo pacman -S fakeroot # 构建chrome所需工具
sudo pacman -S yay
yay -S google-chrome
yay
```


---

## Linux桌面快捷键

像`Alt+F2`和`Ctrl+Alt+F1`等等都是所有Linux桌面都有的快捷键

- Alt+F2: 弹出搜索框，功能类似mac的spotlight_search
- Ctrl+Alt+F1/F2(注1): 似乎是切换recovery模式或启动模式的按键，对于桌面版Linux来说Ctrl+Alt+F1切换成图形界面，那么F2就是cli_mode/text_mode
- Ctrl+Alt+T: 新建terminal窗口

注1: manjaro/arch里text_mode和desktop_mode互相切换还是挺容易的，Ubuntu则稍微麻烦点

以下快捷键都是我在KDE桌面验证过的，未在Ubuntu/GNOME下试过，可能是KDE专用快捷键吧

- win+1: 切换到任务栏位置1的应用，跟windows的win+1快捷键功能一样
- alt+1: 切换到tab 1
- alt+`: 同一个应用的多个窗口间切换  
- win+tab: switch workspace
- win+w/F11: 全屏/撤销全屏(KDE/plasma的Meta键是win键的意思，在mac系统meta是alt)
- F12: 开/关yakuake下拉式terminal
- alt+F1: 在开始菜单中搜索
- win+e: 开文件浏览器
- (fn)F1/F2: 屏幕亮度
- (fn)F3: 键盘背光开关
- (fn)F10: 系统设置
- (fn)F11: 截屏

