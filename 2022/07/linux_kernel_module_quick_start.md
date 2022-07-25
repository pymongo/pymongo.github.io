# [kernel module](/2022/07/linux_kernel_module_quick_start.md)

## source

任意目录下随便新建一个 mod.c 和 Makefile

```cpp
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
// WARNING: modpost: missing MODULE_LICENSE()
// available license: grep MODULE_LICENSE -B 27 /lib/modules/`uname -r`/build/include/linux/module.h
MODULE_LICENSE("GPL");
static int __init lkm_example_init(void) {
    // KERN_INFO is one of dmesg priority
    printk(KERN_INFO "Hello, World!\n");
    return 0;
}
static void __exit lkm_example_exit(void) {
    printk(KERN_INFO "Goodbye, World!\n");
}
module_init(lkm_example_init);
module_exit(lkm_example_exit);
```

Makefile 注意缩进要用 Tab 不能用 4 个空格否则会报错: `Makefile:4: *** missing separator`

```
obj-m += mod.o
all:
    make -C /lib/modules/`uname -r`/build M=$(PWD) modules
```

\`uname -r\` 或者写成 `$(shell uname -r)` 都行

---

## test

```
[w@ww temp]$ modinfo mod.ko
filename:       /home/w/temp/mod.ko
license:        MIT
vermagic:       5.10.131-1-MANJARO SMP preempt mod_unload 
name:           mod
retpoline:      Y
depends:        
srcversion:     E6F527FD6F185B53025154A
[w@ww temp]$ sudo insmod mod.ko
[sudo] password for w: 
[w@ww temp]$ lsmod | grep mod
mod                    16384  0
dm_mod                155648  9 dm_thin_pool,dm_bufio
nvidia_modeset       1146880  36 nvidia_drm
nvidia              40837120  2127 nvidia_uvm,nvidia_modeset
[w@ww temp]$ sudo rmmod mod
```

```
$ sudo dmesg -T --follow
[Mon Jul 25 10:42:17 2022] Hello, World!
[Mon Jul 25 10:42:17 2022] audit: type=1106 audit(1658716943.681:2416): pid=235457 uid=1000 auid=1000 ses=2 msg='op=PAM:session_close grantors=pam_systemd_home,pam_limits,pam_unix,pam_permit acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/2 res=success'
...
[Mon Jul 25 10:42:53 2022] Goodbye, World!
```

可以将测试流程做成 make 一个工作流

```
test:
    sudo dmesg --clear
    sudo insmod lkm_example.ko
    sudo rmmod lkm_example.ko
    dmesg
```

---

LKM = Loadable Kernel Module

Reference: <https://blog.sourcerer.io/writing-a-simple-linux-kernel-module-d9dc3762c234>
