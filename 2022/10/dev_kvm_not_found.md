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

## 跟安卓虚拟机通信

安卓文本->宿主机: 默认配置下安卓模拟器下复制文本，会同步到宿主机的 clipboard

但宿主机复制文本不会同步在安卓

宿主机文本->安卓: 打开模拟器设置->phone 通过发短信将长文本发给手机， 少于一行的内容可用 `adb shell input text xxx`

文件共享的话用 android studio 自带的 device file explorer 浏览文件即可

## 安卓机翻墙

android studio clipboard(粘贴版)共享在 Linux 下有问题
手机->宿主机可以，宿主机->手机不幸

adb 发文本又有长度限制，网上说可以「发短信」
于是我把 clash 代理配置文件内容，通过短信发给模拟器

后来我懒得给模拟器装 clash 客户端
模拟器打开 系统设置->代理设置 10.0.0.2:7890
共用宿主机翻墙

---

(10.0.0.2 就是模拟器内宿主机的固定 IP)
