# [win和mac共享文件夹](/2020/04/win_mac_share_files.md)

首先要保证win和mac在同一个局域网内，通过smb协议分享文件

## win分享文件夹给mac

[参考](https://www.online-tech-tips.com/mac-os-x/connect-to-shared-folder-on-windows-10-from-mac-os-x/)

概述：

1. win将用户文件夹内的某个文件夹设置为共享(注意开放读写权限)
2. win将防火墙、控制面板中启用文件分享
3. mac-finder的sidebar勾选「Connected Servers」
4. finder->Go->Connected Servers，对话框输入smb://+win的IP，然后要求输入win的用户密码

开了ShadowSocks也能连上共享文件夹，开了OpenVPN的话还没测试

!> 注意：在mac上删除win共享的文件会不会进入回收站

## mac共享文件给win

1. System Preferences->Sharing，默认会分享用户的Public文件夹
2. 点击Sharing->Options->「Windows File Sharing」下面要打勾
3. win-explorer 地址栏输入\\+mac的IP
4. 输入mac的用户名和密码

同样的在win上删除mac共享的文件会不会进入回收站

!> 注意windows能看到mac的所有文件，还好没有root用户的权限
