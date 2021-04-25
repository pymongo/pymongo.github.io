# [linux ntfsfix](/2021/04/ntfsfix.md)

最近给manjaro系统接上dolphin报错`Error mounting /dev/sda1`

查阅资料后发现用: `sudo ntfsfix /dev/sda1` 后就能修复我硬盘了

我突然又想起linux下能不能对NTFS硬盘进行碎片整理呢(disk Defragmentation)?

毕竟系统也预装了一堆ntfs*开头的命令工具，后来发现系统自带工具并没有这功能可以装些相关的第三方工具

为什么NTFS要"碎片整理"呢？ext4和apfs都不需要

同事提醒说系统盘碎片整理有点用，非系统盘没必要碎片整体

---



---

# 解决 manjaro_kde_setting_regional_spell_check_error

带图形桌面的操作系统例如 raspbian, manjaro_kde, macos 都会内置 spell_check 以便系统预装应用可以进行拼写检查

但是 KDE 系统设置的 spell_check 的默认配置是乱码，以下官方截图也是乱码

![](https://userbase.kde.org/images.userbase/e/e7/SpellCheckerSettings.png)

导致 kate 

KDE 用的是 sonnect 作为拼写检查的框架，需要安装以下三个动态

> sudo pacman -S aspell hspell libvoikko
