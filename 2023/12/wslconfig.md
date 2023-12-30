# [.wslconfig 设内存](/2023/12/wslconfig.md)

在家用i9笔记本编译代码是比公司电脑快，可是一天的开发出现了好几次的 OOM

gpt4说可能默认wsl最大内存分配限制就是宿主机的一半，我就说明明我都64g内存了还是会有OOM

只好在 ~/.wslconfig 配置中设置一个60G上限

```
[wsl2]
memory=60GB
```
