# [荣耀笔记本装linux](/2021/02/manjaro_kde_config.md)

苦于13年款的mac_air屏幕太小只有11寸，分辨率1368*768看的眼睛难受，而我之前买过的thinkpad因识别不到电池开不了机，surface_pro因未知原因变砖开不了机也进不了BIOS

有朋友说等21年苹果M1芯片的mbp 16寸机出了他就买，正好我也嫌弃11寸的air屏幕太小，我定下了我第一条选购标准——16寸大屏幕

符合16寸+屏幕的就似乎只剩荣耀的magicbook pro 2020款(以下简称荣耀本)，看了下演示为了实现超窄边全面屏，摄像头做成升降式

而且喇叭面积占键盘区域的1/4，大音量+立体声+音质好，这屏幕+喇叭的组合一下子打动了我——就华为(荣耀)笔记本了

最佳实践还是1万+的台式机主用+4k的笔记本外出办公，毕竟5900X比4600H编译代码快2倍以上

---

## 用哪个manjaro镜像?

### U盘引导盘制作

荣耀本的BIOS不支持MBR引导，所以将安装包ISO解压到FAT格式的U盘是不行的，推荐用etcher/raspberrypi_imager制作EFI格式的U盘引导

我发现iso镜像解压到FAT32格式的U盘，启动时报错Unknown filesystem进入grub rescue

grub确实不能用FAT32文件系统去引导，还是只能用raspberrypi_imager制作U盘启动

win10安装的引导盘却可以用FAT32甚至NTFS(看主板支持)

通过`lsblk`发现U盘分区1大小2.2G等于ISO镜像文件的大小，分区2大小4M

再通过`lsblk -f`或KDE_partition_manager发现分区2是vfat格式，分区1是iso966格式

说明我们U盘的体积很小的分区2才是引导分区，主板要选分区2进入manjaro装机环境，如果不慎选错就进了grub rescue只能冷关机了

同理我们manjaro安装后硬盘分区1是体积很小的FAT32引导分区，分区2才是ext4的linux硬盘

由于主板默认都会选择硬盘设备的分区1,因此能正常引导，但我们U盘启动盘分区2才是引导分区，这点要分清楚

### U盘格式化成FAT32(非引导盘)

警告!以下方法仅能当存储U盘用(因为只有一个分区而没有引导分区)，manjaro的grub不能识别!

```
# lsblk，获取U盘的盘符信息
[w@w-manjaro ~]$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    1  58.2G  0 disk 
├─sda1        8:1    1   2.2G  0 part 
└─sda2        8:2    1     4M  0 part 
# (可选-盘符不能输错警告)dd命令删光U盘数据

# fdisk重新规划U盘的分区
$ sudo fdisk /dev/sda
此时进入了fdisk的shell,然后 o,n(新建分区，一路按回车默认就好),w(保存分区信息并退出)

# 格式化
$ sudo mkfs.vfat -F 32 -n 'manjaro' /dev/sda1
格式化后manjaro系统会提示是否挂载U盘，说明操作成功
```

### 尝试xfce

听社区(Rust群)吹manjaro发行版好用，于是我下了manjaro下载页排第一位的xfce_minimal

装完后遭遇显卡驱动问题而黑屏，后来经网友提醒黑屏时按<var class="mark">CTRL+ALT+F2</var>可以进入cli/text模式，cli模式下发现xstart启动报错导致桌面没启动起来，而且触控板也没驱动

xfce的文件浏览器居然不支持new tab，都2021年了还跟windows那个file explorer一样不支持new tab

而且xfce的设置选项太少了(没有nightshift设置)，还不能搜索设置项，懒得修复驱动问题，换KDE！

### 安装系统选open_source_driver?

进入U盘分区2的引导分区后，会进入grub菜单

如果用的是核心显卡例如amd那种CPU/GPU二合一或Intel UHD630则选open source driver

例如amd的核显「只能选open_source_driver」

**只有N卡才选proprietary_driver**

如果N卡点open_source_driver进入系统加载都慢的要死，而且画面还卡

而且此时显卡设备名称会显示成`NV138`而非`GT1030`

### manjaro full和min版的区别

参考: <https://gitlab.manjaro.org/profiles-and-settings/iso-profiles/-/blob/master/manjaro/kde/Packages-Desktop>

带extra开头的包就是full多装的包

由于full版多了太多类似steam这种***垃圾***包，所以「**强烈建议安装min版**」

### 解决min版emoji显示成方框

min版没装emoji的字体，导致crates插件emoji图标全乱码，务必安装`noto-fonts-emoji`字体

### 卸载min版自带软件

noto是manjaro_kde默认字体，ttf-dejavu和adobe-source-code-pro-fonts提供了sans字体，是必须的

dejavu让vscode的英文字体非常好看

- manjaro-hello manjaro-application-utility manjaro-documentation-en # 要一起卸载，因为互相依赖
- okular # poppler-data删掉后每次开机都会提醒很烦，use chrome to view PDF
- kdeconnect sshfs
- kinfocenter # powerdevil optional require
- kaccounts-providers
- kwallet-pam kwalletmanager # turnof kwallet first, kwallet can't delete
- kcalc firefox konversation
- terminus-font(没啥用也不好看)
- adobe-source-han-sans-jp-fonts
- adobe-source-han-sans-kr-fonts
- adobe-source-han-sans-cn-fonts(纯英文工作机用)
- ruby
- inxi partitionmanager
- tlp powerdevil powertop # 笔记本不要卸载，否则休眠后唤醒可能卡死

software token由于opennetwork依赖故无法删除

### 卸载full版无用的系统自带

full版manjaro无用的自带包举例:

- 外设类: 打印机、扫描机(skanlite)、光驱(k3b)
- 无用的网络工具: kget(下载器)、thunderbrid(邮件客户端)、konversation(Internet Relay Chat)

卸载manjaro-steam后需要清理以下残留文件

> rm -rf .steam .steampath .steampid ~/.local/share/Steam

### 获取linux系统的安装时间

> head /var/log/pacman.log

或者查看硬盘文件系统创建时间

> sudo tune2fs -l /dev/nvme0n1p1 | grep "Filesystem created"

---

## KDE显示与驱动

### 摄像头/指纹锁驱动检查

荣耀本的埋藏式摄像头可以用VLC打开，前置摄像头能正常工作

不过荣耀本的指纹锁貌似KDE无法设置，Ubuntu据说有指纹锁的设置项

### 屏幕亮度调节的方法

一共有三种主动调亮度的方法

1. 任务栏右下角的battery_and_brightness图标
1. 笔记本功能键
2. 改文件/sys/class/backlight/xxx/brightness   

如果长时间不操作，KDE默认会降低屏幕亮度，类似win10进入待机前会降低屏幕亮度几秒

但是KDE并不会像win10动动鼠标恢复原亮度，KDE待机时屏幕变暗后就不会变回来

建议关掉待机让屏幕变暗的相关设置

### dark theme

1. Appearance->Theme改成BreeezeDark
2. application_style->configure_gtk...->Adwaita-dark
3. nightshift直接在设置里搜索就能改到

### 4k屏200%缩放

win10的建议是1080P屏幕用125%的缩放，mac的建议是4k屏用200%的缩放

4k@60Hz屏适合将scale(devicePixelRatio)设为200%，1080P的话用150%缩放

![](kde_settings_4k_60.png)

¶ KDE任务栏配置

右键任务栏或开始菜单选择alternative即可更换组件，也可以右键任务栏edit panel去掉无用的trash等widget

可以把开始菜单+任务栏从像win10改成像win7，但我觉得默认主题够用了

![](kde_task_manager.png)

---

## 常用软件安装

### 必装Rust/C/C++

```
sudo pacman -Syu
# base-devel include gcc, binutls, pkgconf, fakeroot
sudo pacman -S base-devel cmake lld
```

gcc和llvm是两个比较常用的编译器后端，例如clang就是llvm C++的前端

gcc可以通过输入的文件后缀名区分用哪一个编程语言的前端，所以gcc可以同时编译C和汇编

gccrs项目就希望开发一个gcc的Rust前端，可以把Rust代码通过gcc后端进行编译

本身Rust也提供了rust-gdb和rust-lldb工具兼顾gcc和llvm

¶ C/C++工具生态

- qt专用IDE: qt_creator
- fmt工具: clang-format
- 静态分析/lint: cppcheck, clang的clang-tidy和clazy-standalone
- 堆内存泄漏检查工具: valgrind(也能用来分析Rust应用)
- C/C++解释器: root/cling

¶ pacman的rustup

pacman安装的rustup的一个好处是可以不把`~/.cargo/bin`加到PATH环境变量中(只要没用cargo audit等第三方cargo子命令或可执行文件)

另外一个好处则是隔离了rust自带的可执行文件和自己装第三方可执行文件，如果没cargo install其它可执行文件，不需要把`~/.cargo/bin`加到PATH中

如果用rustup装，cargo-fmt和cargo-audit混在了`~/.carbo/bin`一个文件夹内

pacman装的/usr/bin/rustc等可执行文件其实是个/usr/bin/rustup的软链接，

ra等工具链的安装和配置请看我另一篇文章: [vscode配置Rust环境](/archive/vscode/vscode_setup_rust.md)

### 必装java

由于idea等众多java软件依赖jvm,所以还是必须装上`jdk-openjdk`

Ubuntu用**update-java-alternatives**切换java版本，而arch则使用**archlinux-java**

### 必装yay和chrome

#### 获取pacman的历史操作

> cat /var/log/pacman.log | grep "\[PACMAN\]"

需要先禁用KDE wallet再装chrome(keyring相关应用)

否则keyring出问题的话，chrome保存的密码就为空，需要signout后delete_account再改好keyring后登陆chrome才能显示密码

```
# yay 依赖base-devel的fakeroot
sudo pacman -S yay # 用类似的aur_helper工具yaourt也行
yay -S google-chrome
```

### 安装MySQL

```bash
sudo pacman -S mysql
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl start mysqld
sudo mysql -uroot -p

mysql> CREATE USER 'me'@'localhost' IDENTIFIED BY 'me';
mysql> GRANT ALL PRIVILEGES ON mydb.* TO 'me'@'localhost';
mysql> FLUSH PRIVILEGES;
mysql> quit

mysql -ume -pme
mysql> select current_user();
mysql> show databases;
```

¶ mongodb, redis

我项目里数据库主要用mongodb和redis，照着mongodb的arch wiki教程装完后改下systemd配置文件的ExecStart即可启动

¶ docker

至于docker安装可以参考 <https://github.com/vkill/Archlinux/blob/master/Docker.md>

### proxy代理工具

详见我另一篇文章: [manjaro KDE proxy setting](/2021/04/manjaro_kde_proxy.md)

### 安装输入法

请看我另一篇文章: [manjaro/KDE安装小鹤双拼](/2021/02/manjaro_linux_fcitx5_xiaohe_shuangpin.md)

### (可选)安装微信

首先需要安装以下字体避免微信中的中文字体乱码(adobe思源黑体不能解决乱码问题)

> sudo pacman -S wqy-microhei wqy-zenhei

(建议把微软字体`ttf-ms-fonts`也装了)然后再安装deepin包装过的wine套壳微信

> yay -S deepin-wine-wechat

wine应用在高分屏(4k屏)下没有缩放，会显得非常小，以下命令可以打开wine设置

> WINEPREFIX=~/.deepinwine/Deepin-WeChat/ winecfg

将显示字体DPI从96改成192(就是整体放大两倍)，微信UI和字体都会变大2倍

### (可选)安装办公/教学/演示软件

- gnome-todo(虽不如mac的凑合能用)
- screenkey(按键输入回显，用于录制教学视频或演示)
- peek(录屏gif格式，类似licecap)
- sunloginclient(远程桌面、远程控制)
- filelight: 磁盘使用分析工具

### 安装spell check

详细过程看我另一篇文章: [解决 KDE spell check 报错](/2021/04/manjaro_kde_spell_check.md)

### 必装必配samba

!> 必须要先禁用kde wallet，才能更好配置samba

smb协议是一种跨平台文件共享协议(win/mac都内置)，由于linux自带那个ftpd不知道怎么用，看教程安装的vsftpd也启动失败

安装smb的过程可以看我另一篇文章: [win/mac/linux共享文件夹](/2020/04/win_mac_linux_samba_smb_share_files.md)

### 必装vnc server

具体看我另一篇文章: [linux远程控制](/2021/05/manjaro_kde_vnc_screen_share.md)

---

## 系统设置

### keyrings和禁用KDE wallet

禁用掉KDE wallet的**副作用***就是不能记住wifi密码，要按我以下的设置才能重新记住wifi密码

去掉`rm -rf ~/.local/share/keyrings`能让mongodb-compass进入时不再提示输入密码的对话框

但是可能会弹出需要创建keyring的对话框

这时候就需要安装`seahorse`，删掉所有keyrings后在seahorse软件内添加一个`password keyring`并`Set as default`

这时候mongodb-compass就没有keyring相关弹窗了，再查看新建的默认keyring文件发现已经把compass加进去了

```
[w@ww keyrings]$ pwd
/home/w/.local/share/keyrings
[w@ww keyrings]$ tree
.
├── default
└── Default.keyring
[w@ww keyrings]$ cat default
Default[w@ww keyrings]$ cat Default.keyring
[keyring]
display-name=Default
ctime=1621935951
mtime=0
lock-on-idle=false
lock-after=false
// ...
display-name=MongoDB Compass/Connections/f123634e-b97c-4ac4-b030-6fd8f56ddf6c
//...
```

Reference: https://askubuntu.com/questions/65281/how-to-recover-reset-forgotten-gnome-keyring-password

### 自动记住Wifi密码

system_settings->network->connections->wifi_security_tab->storage_password_for_all_users

### terminal(kconsole)

安装类似zsh-completion可以补全命令的参数，但不如zsh强大到能补全systemd的unit名称

注意用zsh的话不要设置`HISTSIZE=`这样会让zsh的历史功能崩掉

> sudo pacman -S bash-completion

取消行数上限: profile->edit->scrolling->unlimit

如果鼠标往上滚动时，terminal不会翻页，输入`reset`重置下就好了

### git config

```
git config --global user.name "w"
git config --global user.email "w@example.com"
git config --global credential.helper store 
#git config --global pull.rebase true # 如果公司严格要求所有commit都是直线不能分叉，那就建议先fetch再slash push/pop和fetch
#https://twitter.com/hayahayayoo/status/1398234421417811969
```

### ssh-agent配置

1. ssh-keygen
2. github账户的密钥管理中加上步骤1生成的公钥
3. (可选)ssh -T git@github.com # 检查步骤2是否成功

如果电脑重启过ssh-agent没启动起来，则执行以下操作   

1. eval `ssh-agent -s` # 一定要eval执行ssh-agent输出的几个修改环境变量的命令
2. ssh-add

然后就可以`ssh -A example.com`在云主机上使用开发机的github_ssh密钥进行pull/push私有仓库代码

### 右键菜单context_menu设置

dolphin's settings->services 中可以关闭部分context_menu的一级菜单，这部分配置在文件系统的:

> /usr/share/kservices5/ServiceMenus

右键菜单的create_new内新建各种libreoffice文件的配置文件在:

> /usr/share/templates

删掉或重命名那几个libreoffice相关的desktop文件就能在右键新建菜单中看不到了

### 全局emacs布局?

工作机从mac换成linux后最不习惯的是不能用Ctrl+F/B/P/N上下左右移动光标

往以下两个gtk/gnome应用的配置文件添加`gtk-key-theme-name="Emacs"`的配置项(可能没啥用)

- ~/.config/gtk-3.0/settings.ini
- ~/.gtkrc-2.0

### 去掉系统一些无用快捷键

screen_edge设置里鼠标移到右上角就显示show desktops这个没用

不需要cmd+L键锁屏(mac的chrome cmd+L是光标移到网址，总是误按)，用krunner输入lock the screen进行锁屏

- 删掉启动krunner的alt+F2，让vscode/idea用这个快捷键
- application_launcher的Alt+F1改成Alt+F6(不能删掉，否则按win不能弹出开始菜单)

### idea配置()

建议用toolbox安装idea更好(通过idea-eval-resetter用上CLion)，因为manjaro源的更新落后arch好几周

linux下的idea首先要安装官方的mac_keymap插件才能导入mac的配置

然后就`Help->Edit Custom Properties`中加以下配置，允许以win键为modifier的快捷键

> keymap.windows.as.meta=true

我的经验是只备份一个idea的keymap和general(字体大小)的配置文件，然后所有jetbrains全家桶共同使用这一个按键配置

### jetbrains-toolbox

jetbranins-toolbox's settings:
- disable auto update: use yay to update, do not update toolbox self update!
- disable tools auto update: 不需要频繁启动, manually update all tools/plugins once a week
- enable keep only the latest version: I wish keep only latest version toolbox
- apperance_theme_dark
- disable apperance_run_at_login

**Do not open toolbox with start_menu or krunner!**

start_menu's toolbox is `/home/w/.local/share/applications/jetbrains-toolbox.desktop`

which refer to `Exec=/home/w/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox`

when I yay update toolbox, start_menu's toolbox still refer to old_version

best_practice: open toolbox by `/usr/bin/jetbrains-toolbox`

### vscode要装aur的

不要装`code-OSS`那个包，会少emacs/remote_ssh等众多插件和配置(因为很多插件都是不开源的license)

---

## 其它

### 千万不要 sudo reboot

一定要执行 sync 命令后再 reboot，或者开始菜单栏的重启，或者用 sudo shutdown -R，否则一旦内核更新但没装载到硬盘后reboot就容易挂了

### 文件管理器F5刷新

注意KDE(dolphin)并不会像mac/windows那样real-time刷新文件列表，如果找不到某个文件，可以按F5刷新

另外一个dolphin常用快捷键是<var class="mark">alt+.</var>可以开关隐藏文件的显示

### Linux桌面快捷键

像`Alt+F2`和`Ctrl+Alt+F1`等等都是所有Linux桌面都有的快捷键

- alt+F2: 弹出搜索框，功能类似mac的spotlight_search
- ctrl+alt+F1/F2(注1): 似乎是切换recovery模式或启动模式的按键，对于桌面版Linux来说Ctrl+Alt+F1切换成图形界面，那么F2就是cli_mode/text_mode
- ctrl+alt+t: 新建terminal窗口

注1: manjaro/arch里text_mode和desktop_mode互相切换还是挺容易的，Ubuntu则稍微麻烦点

以下快捷键都是我在KDE桌面验证过的，未在Ubuntu/GNOME下试过的快捷键

- alt+space: 除了用alt+F2还能用跟mac同样的快捷键呼出krunner
- win+q: 切换activity(每个activity下面可以有多个workspace)
- Ctrl+F1: 切换到workspace1
- win+1: 切换到任务栏位置1的应用，跟windows的win+1快捷键功能一样
- alt+1: 同一个应用内切换到tab 1
- alt+`: 同一个应用内多个窗口间切换  
- win+tab: switch workspace
- win+w / F11: 全屏/撤销全屏(KDE/plasma的Meta键是win键的意思，在mac系统meta是alt)
- win + +/-: 放大镜，快捷键跟windows一样
- Ctrl+Esc: 打开system_activity，类似windows任务管理器
- F12: 开/关yakuake下拉式terminal
- alt+F1: 在开始菜单中搜索
- win+e: 开文件浏览器
- alt+.: 文件管理器开关隐藏文件的显示
- win+.: emoji picker
- Ctrl+; fcitx粘贴板，功能类似IDEA的cmd+shift+v，可以挑选最近几次复制内容进行粘贴
- (fn)F1/F2: 屏幕亮度
- (fn)F3: 键盘背光开关
