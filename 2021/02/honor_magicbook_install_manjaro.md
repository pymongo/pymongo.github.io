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

dark_mode要把Appearance->Theme改成BreeezeDark，还要把application_style->gnome/gtk_application_style的theme改成dark(改完后才能让vscode和chrome的菜单栏也变成黑暗主题)

如果外接4k屏，记得用HDMI2.0的线，笔记本HDMI接口支持输出4k@60fps的画面，此时需要将KDE的global scale设为200%

也就是js的`window.devicePixelRatio`属性值，这样用4k屏会将4个像素点当一个去用

## KDE任务栏配置

右键任务栏或开始菜单选择alternative即可更换组件，也可以右键任务栏edit panel去掉无用的trash等widget

![](kde_task_manager.png)

## 摄像头/指纹锁驱动检查

荣耀magicbook的摄像头可以用VLC打开，没什么问题

指纹锁(Fingerprint)的话只有win10和Ubuntu系统才有相关设置，我暂时不想用第三方的，KDE 5.21内置了指纹锁的设置菜单(现在manjaro用的还是5.20)

## 安装gcc和rustup

建议先更新glibc，否则gcc安装后会提示glibc版本太低，但是更新glibc会同时更新gtk,KDE等，可能在安装KDE的更新时图形界面会没掉然后黑屏，切换到cli模式再sudo reboot即可

```
sudo pacman -Su glibc # 更新glibc
sudo pacman -S binutils gcc make cmake # 安装gcc/g++, binutils等build_tools
sudo pacman -S pkgconf # Rust编译actix-web之类的需要pkg-config去寻找openssl动态链接库
# openssl在archlinux一般都自带了，无需额外安装
```

由于arch上面的软件包版本都很新，如果不想影响系统的glibc依赖组件，可以拉源码自行安装gcc

通过包管理pacman安装的rustup和rustup.rs的rustup安装脚本的区别在于

1. cargo/rustup的路径在/usr/bin，rust-analyzer的路径还在~/.cargo/bin
2. pacman的rustup不能self update，需要pacman进行更新

## 安装chrome

```
sudo pacman -S fakeroot # 构建chrome所需工具
sudo pacman -S yay
yay -S google-chrome
```

通过`yay -Ql google-chrome`得知chrome安装到了`/opt/google/chrome/`，而pacman的包一般都安装在`/usr/share`

## 卸载无用的系统自带

我用Linux又不玩游戏，manjaro KDE完整版内置了steam我不能接受，不小心点开steam又继续下载安装一堆垃圾

```
sudo pacman -Rns steam-manjaro
cd ~ && rm -rf .steam .steampath .steampid 
rm -rf ~/.local/share/Steam
```

除了steam，无用的系统内置包还有:

- firefox(用chrome就够了)
- cantata(音乐播放器，功能与VLC重复)
- k3b(都2021年了谁还用光驱啊)
- kget(用浏览器下载文件就够了，不需要下载工具)
- thunderbrid(工作不用邮件，不需要邮件客户端)
- hp device manager(没有打印机)

## 右键菜单context_menu设置

dolphin's settings->services 中可以关闭部分context_menu的一级菜单，这部分配置在文件系统的:

> /usr/share/kservices5/ServiceMenus

右键菜单的create_new内新建各种libreoffice文件的配置文件在:

> /usr/share/templates

删掉或重命名那几个libreoffice相关的desktop文件就能在右键新建菜单中看不到了

## 双拼输入法安装

请看我这篇文章: [manjaro/KDE安装小鹤双拼](/2021/02/manjaro_linux_fcitx5_xiaohe_shuangpin.md)

## 安装微信

首先需要安装以下字体避免微信中的中文字体乱码

> yay -S wqy-microhei wqy-zenhei

然后再安装deepin包装过的wine套壳微信

> yay -S deepin-wine-wechat

wine-微信故障排除参考了[这篇文章](https://blog.csdn.net/CHAOS_ORDER/article/details/105419366)

## 全局emacs布局?

工作机从mac换成linux后最不习惯的是不能用Ctrl+F/B/P/N上下左右移动光标

往以下两个gtk/gnome应用的配置文件添加`gtk-key-theme-name="Emacs"`的配置项，如果应用支持emacs keymap就会优先选用emacs布局

- ~/.config/gtk-3.0/settings.ini
- ~/.gtkrc-2.0

## git

```
git config --global user.name "w"
git config --global user.email "w@example.com"
git config --global pull.rebase false
git config --global credential.helper store 
```

## ssh-agent配置

1. ssh-keygen
2. github账户的密钥管理中加上步骤1生成的公钥
3. (可选)ssh -T git@github.com # 检查步骤2是否成功
4. eval `ssh-agent -s` # 一定要eval执行ssh-agent输出的几个修改环境变量的命令
5. ssh-add # 第一次用ssh-agent需要将本机的公钥添加到agent中

然后就可以`ssh -A example.com`在云主机上使用开发机的github_ssh密钥进行pull/push私有仓库代码

上述配置完后，只要ssh-agent还在后台进程中，远程云主机拉代码时就能使用开发机的密钥，做到服务器不存储任何git密钥(安全)

## idea配置

idea和pycharm这类有免费的社区版的软件用pacman安装即可，像CLion这样的就得AUR或者官网下载

由于我2年的mac开发习惯上90%的时间用idea，10%的时间用vscode，所以idea熟悉了macOS keymap实在改不了，只好把mac上idea的配置

linux下的idea首先要安装官方的mac_keymap插件才能导入mac的配置

然后就Help->Edit Custom Properties中加入以下配置允许以win键为modifier的快捷键

> keymap.windows.as.meta=true

我的经验是只备份一个idea的keymap和general(字体大小)的配置文件，然后所有jetbrains全家桶共同使用这一个按键配置

## vscode配置

不习惯Ctrl+f/b/n/p没法移动光标，所以我改成了emacs keymapping

```
{
    "files.autoSave": "afterDelay",
    "window.zoomLevel": 1,
    "terminal.integrated.macOptionIsMeta": true,
    "rust-analyzer.server.path": "~/.cargo/bin/rust-analyzer",
    "rust-analyzer.updates.channel": "nightly",
    "rust-analyzer.cargo.allFeatures": true,
    "vim.insertModeKeyBindings": [
        {
            "before": [
                "j",
                "j"
            ],
            "after": [
                "<Esc>"
            ]
        }
    ]
}
```

## mongodb安装

照着mongodb的arch wiki，安装编译好的二进制分发，然后改下mongodb的systemd ExecStart配置即可使用

## dolphin文件管理器刷新

注意KDE并不会像mac/windows那样real-time刷新文件列表，如果找不到某个文件，可以按F5刷新

---

## Linux桌面快捷键

像`Alt+F2`和`Ctrl+Alt+F1`等等都是所有Linux桌面都有的快捷键

- Alt+F2: 弹出搜索框，功能类似mac的spotlight_search
- Ctrl+Alt+F1/F2(注1): 似乎是切换recovery模式或启动模式的按键，对于桌面版Linux来说Ctrl+Alt+F1切换成图形界面，那么F2就是cli_mode/text_mode
- Ctrl+Alt+T: 新建terminal窗口

注1: manjaro/arch里text_mode和desktop_mode互相切换还是挺容易的，Ubuntu则稍微麻烦点

以下快捷键都是我在KDE桌面验证过的，未在Ubuntu/GNOME下试过，可能是KDE专用快捷键吧

- win+q: 切换activity(每个activity下面可以有多个workspace)
- Ctrl+F1: 切换到workspace1
- win+1: 切换到任务栏位置1的应用，跟windows的win+1快捷键功能一样
- alt+1: 同一个应用内切换到tab 1
- alt+`: 同一个应用内多个窗口间切换  
- win+tab: switch workspace
- win+w/F11: 全屏/撤销全屏(KDE/plasma的Meta键是win键的意思，在mac系统meta是alt)
- F12: 开/关yakuake下拉式terminal
- alt+F1: 在开始菜单中搜索
- win+e: 开文件浏览器
- Ctrl+; 粘贴板，功能类似IDEA的cmd+shift+v，可以挑选最近几次复制内容进行粘贴
- (fn)F1/F2: 屏幕亮度
- (fn)F3: 键盘背光开关
- (fn)F10: 系统设置
- (fn)F11: 截屏
