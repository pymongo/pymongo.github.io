# [clean-dns-bpf 使用体验](2021/10/clean_dns_bpf.md)

<https://github.com/ihciah/clean-dns-bpf>

## check kernel build options (config)

```
[w@ww temp]$ zcat /proc/config.gz | grep CONFIG_XDP_SOCKETS
CONFIG_XDP_SOCKETS=y
CONFIG_XDP_SOCKETS_DIAG=m
[w@ww temp]$ cat /boot/config-$(uname -r) | grep CONFIG_XDP_SOCKETS
cat: /boot/config-5.13.19-2-MANJARO: No such file or directory
[w@ww temp]$ zcat /proc/config.gz | head
#
# Automatically generated file; DO NOT EDIT.
# Linux/x86 5.13.19-2 Kernel Configuration
#
CONFIG_CC_VERSION_TEXT="gcc (GCC) 11.1.0"
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=110100
CONFIG_CLANG_VERSION=0
CONFIG_AS_IS_GNU=y
CONFIG_AS_VERSION=23601
```

## segfault

cargo b 正常但是 cargo bpf build 会 segfault

```
[w@ww clean-dns-bpf]$ cargo bpf build 
   Compiling clean-dns-bpf v0.1.0 (/home/w/repos/clone_repos/clean-dns-bpf)
warning: due to multiple output types requested, the explicitly specified output file name will be adapted for each output type

warning: ignoring --out-dir flag due to -o flag

warning: `clean-dns-bpf` (bin "clean-dns") generated 2 warnings
    Finished release [optimized] target(s) in 0.37s
Segmentation fault (core dumped)
```

虽然我 kernel 支持 XDP (4.8 以上) 但似乎编译 elf 模块就是有 Bug 会段错误

**只好且只能用编译好的 github release 二进制分发的 elf 文件了**

## load/unload xdp

注: wlp4s0 是我 wifi 主板的网卡设备名称

> sudo ip link set dev wlp4s0 xdp obj ~/Downloads/clean-dns.elf 

> sudo ip link set dev wlp4s0 xdp off

## 效果简单评测

加载后主观上似乎看上去 git pull 成功率提高了一点但依旧频繁失败

README 上面 nslookup 我即便不开代理也能解析到 twitter.com 觉得没啥用
