# [Linux 屏幕共享/远程控制](/category/archlinux/linux_screen_share_remote_control.md)

拥有多台电脑建议用vnc实现一台台式机的键盘鼠标显示器控制多台笔记本和树莓派，强力的生产力工具

这个也是keyring相关的应用，client也是用KDE wallet存储server的密码，建议先配置好KDE wallet

## linux display server

主流的就Xorg(X11)和wayland两种，一般都用xorg

想要开启远程控制/屏幕共享服务器前需要知道linux具体用的哪种display server

通过loginctl可以查看当前的display server: `loginctl show-session 1`

## RDP的可行性

RDP是微软的远程控制协议，linux比较多人用xrdp，但似乎KDE用有bug mac连过来就黑屏

由于linux生态都是用vnc为主，还是考察下vnc的可行性

## krdp vnc server

由于国内Rust每周的技术要讨回都在腾讯会议或飞书，而这两个软件不可能提供linux客户端

所以为了方便用性能强悍的台式机进行live coding的分享，我可以让mac通过vnc远程控制我台式机

vnc_server: krdp

vnc_client: krdc, realvnc-vnc-viewer

如果系统没有启用KDE wallet，可以在设置中禁用`store password using KDE wallet`

!> 注意krdp启动后「会闪退到右下角的任务栏图标」，要从任务栏中打开窗口

krdp是KDE全家桶中的Desktop Sharing的server端应用，使用方法很简单，client输入server的IP和密码

server端点接受被远程控制就行了

krdc需要装krdp提供的vnc相关的动态链接库才能选择VNC类型的server进行连接，否则只支持RDP协议

## best vnc client

但是krdc有个致命缺点就是远程控制时鼠标的响应速度太慢了，用起来鼠标卡的要死

realvnc client鼠标很流畅，但是画质略微差点

由于archlinux的realvnc和tigervnc是冲突的，建议realvnc用standalone版本

### realvnc

跨平台，client端免费，server端收费(除了树莓派)

画质较差，比krdc差点，尤其是浏览器鼠标滚动上下翻页时，就会像显卡驱动坏掉那样一帧帧的，从上到下一条横线缓慢的更新画面

而且realvnc画质调整选项少(在options->expert里)，例如内网使用可以把画质调高也不行

最大优点: 画面缩放完美

### tigervnc client

tigervnc居然可以把画质压缩关掉，画质最好，甚至比krdc还要好

而且网页滚动翻页时居然完全不卡(不会像realvnc网页翻页时画面从上到下缓慢更新)，原来翻动树莓派官网时网速跑满10MB/s，相比其它vnc client 3-4M/s好多了

而且延迟低的好处是中文输入法候选词几乎瞬间出现，不会像realvnc那样等一会才能看到候选词，体验极好

唯一缺点: 画面不能缩放，4K屏看1080P的笔记本画面有的不友好(12寸屏看1080P的感觉)

其它缺点: Bug `<` is map to `>`

### macos 自带的 ScreenSharing(client) app

mac 系统设置也自带了 vnc server 

### imac连4k显示的linux

imac_2017款分辨率是4096*2304默认用200%的scale

但是苹果默认只能调几种scale,不能像windows或KDE那样自定义scale

自定义scale还需要在「App Store」安装「Display Menu」

如果imac在默认scale下tigerVNC连4K显示的linux,只能显示1/4的画面，「需要拖动滚动条」才能看完整个屏幕画面

原来是tigerVNC是java应用，在mac默认接受系统的scale认为分辨率只有2048*1152(就像OBS默认也是这个分辨率)

当我用display_menu调成100% scale时，tigerVNC看4k画面全屏时就能居中完美显示了

## Reference:

- <https://askubuntu.com/questions/995870/how-to-access-kde-desktop-remotely>
