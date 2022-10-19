# [/dev/kvm](/2022/10/dev_kvm_not_found.md)

工作时间 wine 启动的钉钉/企业微信老是闪退，这周工作机系统升级后 wine 直接连钉钉都打开不了，一打开就闪退

被迫在 Linux 系统上装 android studio 再开虚拟机去运行钉钉(唯一缺点就是虚拟手机登陆后强制登出我手机登陆的钉钉)

> 我个人又是不喜欢玩手机的，手机屏幕太小，只有坐车/吃饭场合实在无聊想打发时间才玩玩

## fix /dev/kvm not found

android studio 由于是基于 qemu 实现的，在添加 virtual device 的时候直接报错 not found

从 archlinux wiki 的 kvm/qemu 页面以及 asus 主板官方技术支持找到了启用 kvm 的方法了

<https://www.asus.com/support/FAQ/1038245/>

bios 先从 ez_mode->advance_mode 再进入 advance->cpu_configure->SVM_mode->enable

## 检查 CPU 是否启用虚拟化

Linux 可用 lsmod 或者 file /dev/kvm 去检查，windows 系统可以在 任务管理器->性能->CPU->Visualization 中检查

```
> lsmod | grep kvm
kvm_amd               118784  0
kvm                   937984  1 kvm_amd
irqbypass              16384  1 kvm
ccp                   118784  1 kvm_amd
```
