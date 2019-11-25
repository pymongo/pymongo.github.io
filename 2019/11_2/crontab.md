# [crontab - scheduled_task](2019/11_2/crontab)

## CRON表达式

说起定时执行脚本，总联想到setInterval，该学点更高级的知识解决定时任务问题

[corntab格式转换工具](https://crontab.guru/#*/5_*_*_*_*)

corntab总共有五位，以空格区分，分别是 【分 时 日 月 周几】 组成

如 * * * * * 表示每分钟执行一次

## Linux-corntab比rufus-scheduler

肯定还是shell层面的更可靠

```
crontab [-u username]　# 省略用户表表示操作当前用户的crontab
    -e      (**vim** edit crontab tasks)
    -l      (list crontab tasks)
    -r      (Remove everything from crontab:)
```

输入mail命令可以查看crontab任务执行结果的stdout

!> crontab需要开放FullDiskControl给Terminal

## 仅定时执行一次的 at命令

[at/crontab - 鳥哥的Linux私房菜](http://linux.vbird.org/linux_basic/0430cron.php)

使用at前必须启动atd server, 以下是mac版的启动方法

> launchctl load -w /System/Library/LaunchDaemons/com.apple.atrun.plist

---

at命令例子:

```
$ at now + 1 minute
touch ~/a.txt
EOF(Ctrl+D)
```

## crontab例子

r.rb:
```ruby
require 'date'                                                              
File.open('/Users/w/code_archive/ruby/lorem.txt', 'a') do |file|
    file.write(DateTime.now.to_s+"\r\n")
end                      
```

crontab -e:
```
* * * * * /usr/bin/ruby ~/code_archive/ruby/r.rb 
```

## mail command

crontab定时任务的stdout会写在 mail中

> You have new mail in /var/mail/w

存储mail的文件在 /var/mail/$USER or /var/spool/mail/$USER



## nohup ... &

会在当前目录新建一个nohup.out,把命令的stdout都写过去

其他用法

> nohup sh your-script.sh > /path/to/custom.out &
