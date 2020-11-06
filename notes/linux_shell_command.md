# 常常忘记又常用的命令

- du -d 1 -h . | sort -n -r | head -n 20

## 搜索文件名

> find . -iname '*.py'

## 搜索文本

> ag -G '\.rs$' 'dyn ' [.]

> grep -r --include=\*.rs 'dyn ' .

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

快捷键`Esc + . `可以自动填上上一条命令的参数，例如上一条命令是`gcc main.c`，这次输入`g++ `然后再按下Esc+.可以填上文件名main.c

如果服务器正在运行，不要删掉log文件，清空log文件的最佳办法是例如: `echo '' > server.log`

## 查看某个端口被哪个进程占用

- lsof -i :8080
- fuser 80/tcp
- netstat -nlp | grep :80
- ps ef | grep 80