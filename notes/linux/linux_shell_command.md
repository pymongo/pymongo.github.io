# 常常忘记又常用的命令

## 列出最大的20个文件

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

### 数据库文件夹迁移

需求: 系统盘只有30G,aws挂载了一块500G的超好性能SSD放数据库文件，这个挂载盘可以随时挂载到其它机器，便携性好

reference: <https://github.com/vkill/VPS/blob/main/Redis.md>

> sudo rsync -aqxP /var/lib/redis/ /data/redis

用rsync比`cp -r`的好处是「能复制文件的权限」

最后删掉/var/lib/redis文件夹并换成软链接指向 /data/redis，这样

例如mongodb的数据文件的权限都是 mongod:mongod，rsync会把权限复制过去

好像`cp -rp`也能保持权限地复制

## 括号内的nohup

通常我们都用systemd部署项目进程，避免ssh shell内执行的`cargo run &`在离开会话或网络中断时不会因为父进程shell结束而结束

```
(nohup command </dev/null &>/dev/null &)
# or
(command &)
```

## 要用 adduser 添加用户别用过时的 useradd

adduser 是个 perl 脚本，会在 useradd 命令创建完用户后执行一堆配置

我在公司用 useradd 使得 .ssh/authorized_keys 不生效


