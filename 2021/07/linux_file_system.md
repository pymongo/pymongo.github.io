# WIP Linux 文件系统

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
- dev: 设备文件 TODO
- etc: 配置文件
- home: 用户文件夹
- lib/lib64: link to /usr/lib, deprecated on manjaro
- lost+found: ???
- mnt: 外部存储设备挂载，例如挂载U盘会挂载到这个目录
- opt: applications for all users，一般用户装的软件我建议像IDEA那样放在~/.local/share下
- proc: 各个进程文件，以及CPU信息等 TODO
- run: TODO
- sbin: link to /usr/bin, deprecated on manjaro
- srv: http/ftp, but deprecated on manjaro
- sys: TODO
- tmp: 临时文件，一般都是libc::tmpnam之类随机文件系统系统所创建
- usr: /usr/bin + /usr/include + /usr/lib
- var: /var/lib is database datadir, /var/log is log dir
