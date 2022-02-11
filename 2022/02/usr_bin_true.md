# [/usr/bin/true](2022/02/usr_bin_true.md)

[在看这篇 systemd service group 的文档学到的](https://alesnosek.com/blog/2016/12/04/controlling-a-multi-service-application-with-systemd/)

/usr/bin/true 直接返回 subprocess exit code 0

与之相反的是 /usr/bin/false 直接返回 exit code 1

适用于模拟进程成功或者失败而退出的情况
