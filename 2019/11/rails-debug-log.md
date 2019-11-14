# [debug,log](2019/11/rails-debug-log)

## 为rubymine安装debug相关gem

ruby没有自带的debug支持(而python3.7加入与debug相关的新函数)

打断点单步调试还是在IDE里面做比较方便

就像git很难通过命令行查看文件的历史版本，

而tortoiseSVN右键show log就可以查看文件历史

当然git可以安装图形化客户端source_tree

---

想用rubymine的断点调试，需要手动安装以下两个gem

```
gem install debase --pre
gem install ruby-debug-ide
```

## 为logger/log4r添加打印颜色

首先log4r的配置可以看[大师的博文](http://siwei.me/blog/posts/log4r)

logger的使用，我个人比较喜欢给自己的log标红：

```ruby
logger.warn "\e[31;5m" + "-"*40 + "\e[0m" + "\e[31;1m"
logger.error "This is a log"
logger.error "to trace var change"
logger.warn "\e[5m" + "-"*40 + "\e[0m"
```

然后通过`tail -f`命令持续滚屏显示log

> [!NOTE]
tail -f log/puma*.log 表示同时滚屏打印所有 puma开头的log文件

例如有 puma.stderr.log 和 puma.stdout.log

打印属于stdout的文件时，抬头会附加 ==> log/puma.stdout.log <==

> tail -f xxx.log

`\033`或`\e`➕[xxm 是bash shell样式的写法前缀，[API请看这个链接](https://misc.flogisoft.com/bash/tip_colors_and_formatting)

多个属性之间以分号为划分，如 \e[31;5m，\e[0m表示清空设置




