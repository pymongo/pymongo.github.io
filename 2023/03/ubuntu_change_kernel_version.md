# [ubuntu change kernel](/2023/03/ubuntu_change_kernel_version.md)

## Linux image

`apt search linux-image-5.10` 找到 5.10 内核版本中的最新的一个版本

如果是虚拟机的 Linux 建议装 linux-image-virtual ，物理机选择了 xxx-oem 后缀的内核包或者 -aws 之类的后缀也行

由于 apt dist-upgrade 升级系统是用 ubuntu 自行设定的内核版本，想用指定的内核版本只能手动下载安装切换了

> apt install linux-headers-5.10.0-1057-oem linux-modules-5.10.0-1057-oem linux-image-5.10.0-1057-oem

[手动下载内核的 deb 包并安装](https://askubuntu.com/questions/1389585/how-do-i-install-kernel-5-15-7-on-ubuntu-21-10-impish-indri)

## edit grub

大致见过三种 grub 设置

1. GRUB_DEFAULT=saved

我 manjaro 台式机 GRUB_TIMEOUT 调大，切换内核时开机后选择内核

会自动保存使用上一次的设置

2. GRUB_DEFAULT=0

server 版 Ubuntu 台式机的设定，默认选择第 0 项作为开机启动

3. GRUB_DEFAULT="foo>bar"

参考了 <https://meetrix.io/blog/aws/changing-default-ubuntu-kernel.html>

> grep -A100 submenu  /boot/grub/grub.cfg | grep menuentry

这样大致看出有几个选项，但还是得 打开 grub.cfg 文件

**GRUB_DEFAULT** 有「子菜单/二级菜单」的概念，所以一般是 0>2 的写法表示一级菜单的第一个内的二级菜单第三项

第一步，先找到 submenu 一行

> submenu 'Advanced options for Ubuntu' $menuentry_id_option 'gnulinux-advanced-d6d9110d-b51e-42dc-bcb2-ad3990b9f7a2'

复制 `gnulinux-advanced-d6d9110d-b51e-42dc-bcb2-ad3990b9f7a2`

第二步，找到 menuentry 二级菜单想要的一行

例如 一级菜单 Advanced options for Manjaro Linux 的二级菜单 menuentry 示例如下

> menuentry 'Manjaro Linux (Kernel: 5.10.167-1-MANJARO x64)' --class manjaro --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-5.10.167-1-MANJARO x64-advanced-7dd0ae65-a2cb-4aa4-86da-e231b42a06a5'

最后用 > 拼接 第一步和第二步的内容

> gnulinux-advanced-d6d9110d-b51e-42dc-bcb2-ad3990b9f7a2>gnulinux-5.10.0-1057-oem-advanced-d6d9110d-b51e-42dc-bcb2-ad3990b9f7a2

update-grub 后 reboot 完事
