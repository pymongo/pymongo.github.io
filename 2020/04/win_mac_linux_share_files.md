# [win/mac/linux共享文件夹](/2020/04/win_mac_linux_share_files.md)

同一个网络下多个设备间的文件共享，可以`python3 -m http.server 80`开启一个static_file_server，也可以通过蓝牙传输文件

但是蓝牙或HTTP文件传输效率和方便性都远不如smb/samba协议(用FTP也行)

下面介绍下主流操作系统如何开启smb_server和如何连一个smb_server(smb_client)

## win开启smb_server

win将某个文件夹属性设置为共享(注意开放读写权限)即可开启smb_server

如果共享文件夹后其它设备还是连不上，请检查控制面板->防火墙中是否启用文件分享

[参考文章](https://www.online-tech-tips.com/mac-os-x/connect-to-shared-folder-on-windows-10-from-mac-os-x/)

## mac开启smb_server

System Preferences(系统设置)->Sharing，打开file sharing，注意开放读写权限

![](mac_smb_enable_windows_file_sharing.png)

## **linux配置smb**

manjaro_kde都预装了samba的package，samba的核心是smb和nmb两个systemd service

<https://wiki.manjaro.org/index.php/Using_Samba_in_your_File_Manager>

假设系统用户名是w

1. 安装manjaro-settings-samba包，里面包含创建samba用户组等操作的安装脚本
2. (参考下图)右键Download文件夹点share再点创建samba用户w密码跟系统用户相同
3. 检查groups w中是否包含sambashare用户组
4. 检查`sudo pdbedit -L`中是否包含samba用户w
5. 将smb.conf改成以下无需密码的配置
6. ***重启***

![](linux_create_smb_user.png)

修改`/etc/samba/smb.conf`前建议**备份**manjaro-settings-samba脚本配的默认smb配置

根据<https://askubuntu.com/questions/724916/can-read-but-cannot-write-to-samba-share>

share的名字跟文件夹的名字不能是一样的，否则和遇到无法写入的问题

```
[global]
    log file = /var/log/samba/log.%m
    guest ok = yes

[home_w]
    path = /home/w
    read only = yes

[download]
    path = /home/w/Downloads
    writable = yes
```

!> 步骤2只建议在UI上操作，用命令行创建的samba用户可能有各种问题!

(可选)如果连接时无限报错认证失败且日志报错权限不足，则参考linux文档可能是samba没有读取系统用户的权限

!> sudo smbpasswd -a w

¶ 无密码登陆仅在两端都是linux时才行?

可能manjaro的samba版本太高，只有两端都是manjaro时才能无密码登陆

所以别加`guest only`的配置项，让非linux的设备通过用户名登陆

---

## 连接smb_server

假设192.168.1.3的设备已开启smb server

- windows: 直接在文件浏览器的路径栏中输入`\\192.168.1.3`
- mac: finder(访达)菜单栏->Go->Connected Servers，然后输入`smb://192.168.1.3`
- linux: 在file_manager(文件浏览器)地址栏输入`smb://192.168.1.3`
- android: 推荐谷歌商店network_browser
  
注意安卓的network_browser连linux要manual_connect且输入用户名密码不能无密码登陆)

!> 注意删除smb共享文件夹内的文件不会进入回收站而是直接删除

![](android_network_browser_smb_client.png)

我的个人理解是client能看到smb_server的所有文件，但是只能对server给定的几个文件夹有写入权限

---

除了samba的方案我还考虑了FTP,但是远不如samba方便

## Android开启FTP server

MIUI/原生安卓自带的文件浏览器com.android.fileexplorer可以在右上角的下拉菜单中开启FTP服务器

然后win/mac/linux都能在地址栏输入`ftp://192.168.1.3:2121`进行访问

Android的FTP client就只能商店随便找个了，而且我找的ftp_client这个app不支持UTF-8，看不到名字带中文的文件

## mac开启FTP server

旧的mac OS版本在sharing设置界面能开启FTP，我用的11.2.1版本就只能去商店下载QuickFTP Server

## Linux开启FTP server

由于我没解决vsftpd启动报错的原因，故放弃
