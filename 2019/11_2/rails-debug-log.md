# [debug,log](2019/11_2/rails-debug-log)

ruby没有自带的debug支持(而python3.7加入与debug相关的新函数)

打断点单步调试还是在IDE里面做比较方便

就像git很难通过命令行查看文件的历史版本，

而tortoiseSVN右键show log就可以查看文件历史

当然git可以安装图形化客户端source_tree

---

想用rubymine的断点调试，需要手动安装以下两个gem

旧版的rubyMine安装时可能会报错，需要手动在cli环境安装

```
gem install debase --pre
gem install ruby-debug-ide
```

## step into和step out

step out: 如果认为当前语句/方法没问题，Bug不是出自这里，则跳出当前方法/语句

不过rubyMine经常会碰到警告 这是c-level的语句，没法继续step into

这时只好step out。我本人是不太喜欢step over，会跳过下一个方法

> 单步调试时如何只在自己的项目文件中跳转

设置->Debug->Stepping 有个选项是`Ignore non-project source`

不过我勾上以后还是会跳入ruby的代码库中.... 都不知道要按多少次step over才能回到自己的代码中

## 为logger/log4r添加打印颜色

首先log4r的配置可以看[大师的博文](http://siwei.me/blog/posts/log4r)

logger的使用，我个人比较喜欢给自己的log标红：

```ruby
logger.warn "\e[31;5m" + "-"*40 + "\e[0m" + "\e[31;1m"
logger.error "This is a log"
logger.error "to trace var change"
logger.warn "\e[5m" + "-"*40 + "\e[0m"
```

!> 如果日志的量太大,建议用<mark>grep</mark>找到想要的内容,而不是靠文字样式

然后通过`tail -f`命令持续滚屏显示log

> [!NOTE]
tail -f log/puma*.log 表示同时滚屏打印所有 puma开头的log文件

例如有 puma.stderr.log 和 puma.stdout.log

打印属于stdout的文件时，抬头会附加 ==> log/puma.stdout.log <==

> tail -f xxx.log

`\033`或`\e`➕[xxm 是bash shell样式的写法前缀，[API请看这个链接](https://misc.flogisoft.com/bash/tip_colors_and_formatting)

多个属性之间以分号为划分，如 \e[31;5m，\e[0m表示清空设置
