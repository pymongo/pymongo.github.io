# Linux 文件系统

## 文件系统根目录

```
.
..
bin
boot
desktopfs-pkgs.txt
dev
etc
home
lib
lib64
lost+found
.manjaro-tools
mnt
opt
proc
root
rootfs-pkgs.txt
run
sbin
srv
sys
tmp
usr
var
```

- bin: boot所需可执行文件，但在manjaro上这是/usr/bin的软链接
- boot: `df -TH`得知boot是引导分区相关的文件`/dev/nvme0n1p1 vfat 300M 296K 300M 1% /boot/efi`
- dev: 设备文件，同 procfs 一样都是零大小
- etc: 配置文件
- home: 用户文件夹
- lib/lib64: link to /usr/lib, deprecated on manjaro
- lost+found: files recovery by fsck - check and repair a Linux filesystem
- mnt: 外部存储设备挂载，例如挂载U盘会挂载到这个目录
- opt: applications for all users，一般用户装的软件我建议像IDEA那样放在~/.local/share下
- proc: procfs，整个文件夹大小都是 0 读取文件时会请求 kernel 返回相应数据
- run: TODO
- sbin: (system binary)link to /usr/bin, deprecated on manjaro
- srv: Read-only data for services provided by this system, http/ftp, but deprecated on manjaro
- sys: 跟 procfs 同样是零大小的 virtual filesystems - no real files，以文件树结构的方式读取一些 kernel 数据
- tmp: 临时文件，一般都是libc::tmpnam之类随机文件系统系统所创建
- usr: /usr/bin + /usr/include + /usr/lib
- var: Variable data, /var/lib is database datadir, /var/log is log dir


## /etc/fstab

/etc/fstab: static file system information

```
[w@ww chapter04]$ cat /etc/fstab 
# <file system>             <mount point>  <type>  <options>  <dump>  <pass>
UUID=8FF2-3E0E                            /boot/efi      vfat    umask=0077 0 2
UUID=7dd0ae65-a2cb-4aa4-86da-e231b42a06a5 /              ext4    defaults,noatime 0 1
```
