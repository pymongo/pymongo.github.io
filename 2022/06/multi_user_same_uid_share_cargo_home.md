# [multi user share cargo](/2022/06/multi_user_same_uid_share_cargo_home.md)

公司多人共用一台机器 vscode remote 开发只能通过多个 Linux user 让每个人用各自的 gitlab 帐号/密钥去 commit

由于 rustup 之前是装在了 /root/.cargo 和 /root/.rustup 无论是 gitlab CI 的用户 gitlab-runner 还是我们自己新建的用户都没权限去读写这部分文件

想当然试图 chmod /root 让其他用户也能访问 .cargo 和 .rustup 但是

> Authentication refused: bad ownership or modes for directory /root

因为 /root/.ssh 要 700 且 /root/.ssh/authorized_keys 要 600 权限所以不能改 /root 权限

这时候有两个方案:

1. 因为 chmod /root 会影响 ssh 所以迁移 .cargo 到 /data 或 /opt
2. 其他用户的 uid 都改成 0

一开始我用方案一为了让所有用户共用一份 bashrc 配置，我有以下配置

```
export PATH=/home/rust/.cargo/bin:$PATH
export RUSTUP_HOME=/home/rust/.rustup
export CARGO_HOME=/home/rust/.cargo
```

其实就是将 /root 下的 .cargo 和 .rustup 文件夹 cp 到 /home/rust (为啥没用 /data /opt 之类是因为这个位置我们挂载了一块超快的 ssd)

```
useradd --create-home --gid root u1
useradd --create-home --gid root u2
# change user u1 and u2 uid to 0
vim /etc/passwd
```

随后 u1 用户就跟 root 一样的权限，而且还可以跟 root 用户隔离开 ssh/git 配置

---

多人共用台式机开发，每人创建 Linux 用户以隔离各自的 git/ssh 帐号配置

考虑多人共享第三方库缓存/配置，希望所有用户都共用 rust/conda/nodejs
但 .cargo/.conda 等文件都默认装在 /root 下没权限

最简单的方案是把用户的 uid 改成 0 (才知道用户 uid 可以相同) 
或软件装在 /data 开放权限来共用

https://twitter.com/ospopen/status/1541677689106739201

## chown home 之后要删掉 .vscode

home 目录 chown -R 成 root 

不删掉 .vscode-server 的话 vscode remote 就没法用了
