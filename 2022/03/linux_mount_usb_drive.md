# [linux mount usb](/2022/03/linux_mount_usb_drive.md)

还是用 U 盘拷贝大文件到公司的服务器机柜传输效率最快

以公司的戴尔工作站 SSD + 机械硬盘的机器为例

插入 U 盘前的 lsblk

```
[root@bogon ~]# lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    0   1.8T  0 disk 
├─sda1        8:1    0   150M  0 part 
├─sda2        8:2    0   128M  0 part 
├─sda3        8:3    0   1.8T  0 part /data
└─sda4        8:4    0   990M  0 part 
sr0          11:0    1  1024M  0 rom  
nvme0n1     259:0    0 238.5G  0 disk 
├─nvme0n1p1 259:1    0   600M  0 part /boot/efi
├─nvme0n1p2 259:2    0     1G  0 part /boot
├─nvme0n1p3 259:3    0  15.6G  0 part 
├─nvme0n1p4 259:4    0    70G  0 part /
└─nvme0n1p5 259:5    0 151.3G  0 part /home
```

插入 U 盘后的 lsblk

```
sda           8:0    0   1.8T  0 disk 
├─sda1        8:1    0   150M  0 part 
├─sda2        8:2    0   128M  0 part 
├─sda3        8:3    0   1.8T  0 part /data
└─sda4        8:4    0   990M  0 part 
sdc           8:32   1  58.2G  0 disk 
└─sdc1        8:33   1  58.2G  0 part 
sr0          11:0    1  1024M  0 rom  
nvme0n1     259:0    0 238.5G  0 disk 
├─nvme0n1p1 259:1    0   600M  0 part /boot/efi
├─nvme0n1p2 259:2    0     1G  0 part /boot
├─nvme0n1p3 259:3    0  15.6G  0 part 
├─nvme0n1p4 259:4    0    70G  0 part /
└─nvme0n1p5 259:5    0 151.3G  0 part /home
```

看看多出来的 /dev/sdc 是啥

```
[root@bogon ~]# file /dev/sdc
/dev/sdc: block special (8/32)
```

然后用 mount 命令挂载 block device

```
[root@bogon ~]# mount /dev/sdc1 /var/run/media/usb
mount: /var/run/media/usb: mount point does not exist.
[root@bogon ~]# mkdir -p /var/run/media/usb
[root@bogon ~]# mount /dev/sdc1 /var/run/media/usb
[root@bogon ~]# ls /var/run/media/usb/
TUF-GAMING-X570-PLUS-WIFI-ASUS-4204.CA
```

一般挂载到 /mnt/usb_drive_name 或者像 manjaro 一样挂载到 /var/run/media/$USER/usb_drive_name

拔出 U 盘前取消挂载: `umount /dev/sdc1`
