# [/usr/bin/shuf](/2023/03/usr_bin_shuf)

/dev/urandom 和 /dev/random 可以生成任意 byte 的随机数

> head -c 1 /dev/random | hexdump

今天看到 shuf 命令也可以生成随机数

> shuf --head-count=3 --input-range=1-10 --repeat

shuf 更多用于机器学习打乱数据集

例如这个从 cheat.sh/shut 抄过来的例子

```
# Randomize the order of lines in a file and output the result:
shuf dataset.csv
```
