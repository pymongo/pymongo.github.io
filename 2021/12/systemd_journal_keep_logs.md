# [记得检查 journal 日志持久化](2021/12/systemd_journal_keep_logs.md)

今天在公司一台测试机器上 systemd 部署时忘了初始化 journal 一些配置

journalctl 日志存到内存中导致 systemctl restart 之后日志丢失

让同事 debug 的时候找不到重要的报错日志，下次要记得在新机器 `cat /etc/systemd/journald.conf | grep Storage` 确认日志持久存储到磁盘

https://unix.stackexchange.com/questions/159221/how-do-i-display-log-messages-from-previous-boots-under-centos-7
