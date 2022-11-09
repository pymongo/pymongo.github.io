# [windows sshd](/2022/11/windows_start_sshd.md)

settings->optional features->openssh server

> (admin powershell)net sshd start

---

客户端给 windows openssh-server 进行 ssh-copy-id 不好使

authorized_keys 文件会写入 `ECHO 处于打开状态`

手动写入公钥也不能免密码登陆
