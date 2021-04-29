# 常常忘记又常用的命令

- du -d 1 -h . | sort -n -r | head -n 20

## 搜索文件名

> find . -iname '*.py'

## 搜索文本

> ag -G '\.rs$' 'dyn ' .

> grep -r --include=\*.rs 'dyn ' .

## 打印某文件的绝对路径

```bash
[w@w-manjaro samba]$ readlink -f smb.conf 
/etc/samba/smb.conf
```

## 清理所有node_modules和target文件夹

brew install trash

> find . -name node_modules -type d -prune -exec trash {} +

> find . -name target -type d -prune -exec trash {} +

### ag和grep的性能对比

PWD=~/.rustup/toolchains/nightly-x86_64-apple-darwin

```
> time ag -G '\.rs$' 'dyn ' .
ag -G '\.rs$' 'dyn ' .  0.05s user 0.08s system 113% cpu 0.115 total
```

```
> time grep -r --include=\*.rs 'dyn ' .
ag -G '\.rs$' 'dyn ' .  0.05s user 0.08s system 113% cpu 0.115 total
```

## sed命令

类似awk，对文本进行处理

## terminal技巧

快捷键 `Alt + .` 或 `Esc + .` 可以自动填上上一条命令的参数，例如上一条命令是`gcc main.c`，这次输入`g++ `然后再按下Esc+.可以填上文件名main.c

如果服务器正在运行，不要删掉log文件，清空log文件的最佳办法是例如: `echo '' > server.log`

## 查看某个端口被哪个进程占用

> sudo netstat -nlp | grep :6379

不推荐用 `lsof -i :8080`, centos 上没有 lsof 指令

## Linux查看硬件信息相关命令

lshw(ubuntu), mhwd(manjaro)

### 查看电脑的制造商

> sudo dmidecode | grep -B1 -A2 "Manufacturer: HUAWEI"

### 查看SSD读写次数

> sudo smartctl -a /dev/nvme0n1p2
