# [依赖用 git ssh 链接](/2022/03/cargo_dep_git_ssh.md)

一旦 cargo 想用 git 依赖就一定要用 rev 锁版本，这是工程原则问题

mylib = { git = "http://git.example.com/wuaoxiang/demo", rev = "43f86720" }

# git@code.baihai.co:wuaoxiang/jupyter_client_demo.git

从 gitlab 上复制的 ssh repo 链接是这样:

> git@git.example.com:wuaoxiang/demo.git

但需要改成一下格式才能让 cargo 下载到依赖

mylib = { git = "ssh://git@git.example.com/wuaoxiang/demo.git", rev = "43f86720" }
