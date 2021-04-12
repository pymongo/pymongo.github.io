# [smarctl ssd lifespan](/2021/04/smartctl_ssd_lifespan.md)

影响固态硬盘的寿命主要因素是数据写入量(不考虑断电等意外因素)，可以认为从SSD中读数据对SSD寿命损耗几乎为0,只有往SSD写数据时才会损耗SSD寿命

可以通过`smartctl`命令工具查看某个硬盘的数据写入量，不过在这之前还得用`df -h`获取硬盘挂载到FileSystem的位置

```
[w@w-manjaro ~]$ df -h
df: /run/user/1000/doc: Operation not permitted
Filesystem      Size  Used Avail Use% Mounted on
dev             7.6G     0  7.6G   0% /dev
run             7.6G  1.6M  7.6G   1% /run
/dev/nvme0n1p2  469G   94G  351G  22% /
tmpfs           7.6G  530M  7.1G   7% /dev/shm
tmpfs           4.0M     0  4.0M   0% /sys/fs/cgroup
tmpfs           7.6G   72M  7.5G   1% /tmp
/dev/nvme0n1p1  300M  312K  300M   1% /boot/efi
tmpfs           1.6G  112K  1.6G   1% /run/user/1000
[w@w-manjaro ~]$ sudo smartctl -a /dev/nvme0n1p2
[sudo] password for w: 
smartctl 7.2 2020-12-30 r5155 [x86_64-linux-5.9.16-1-MANJARO] (local build)
Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Model Number:                       SAMSUNG MZVLB512HBJQ-00000
...
Total NVM Capacity:                 512,110,190,592 [512 GB]
...
NVMe Version:                       1.3
...
Namespace 1 Formatted LBA Size:     512
Namespace 1 IEEE EUI-64:            002538 8701040091
Local Time is:                      Mon Apr 12 18:10:49 2021 CST
...
=== START OF SMART DATA SECTION ===
...
Data Units Read:                    45,848,302 [23.4 TB]
Data Units Written:                 6,245,679 [3.19 TB]
Host Read Commands:                 443,256,209
Host Write Commands:                138,004,591
Controller Busy Time:               481
Power Cycles:                       69
Power On Hours:                     380
Unsafe Shutdowns:                   20
Media and Data Integrity Errors:    0
Error Information Log Entries:      161
...
Error Information (NVMe Log 0x01, 16 of 64 entries)
No Errors Logged
```

> sudo smartctl -a /dev/nvme0n1p2

smartctl的输出内容有部分省略(...表示省略)，可以看到我这个用了2个多月的硬盘竟然发生了20次`unsafe shutdown`(意外断电)

估计大部分都是因为之前装manjaro显卡驱动坏了没图形界面，我长按电源键好几次进行冷关机

2021-02买的电脑，2021-04-12发现有SSD有20次unsafe_shutdown，希望这个unsafe_shutdown的数字能一直保持在20

---

以三星960 evo为例，1TB款Warranty(保修)参数是400TBW，TBW=TB written

所以三星的固态的质保期大约都是写入量在400倍容量以内，按照行业一般约定一个SSD写入3000倍自身容量的数据是没问题的

我的SSD用了2个多月，写入22TB,一年大约能写入130TB，这样看用3-4年是没问题的，

起码要用10几年才年触及写入3000倍容量这个上限，不过那时候早就换成16核+32G内存+1TB硬盘的电脑了
