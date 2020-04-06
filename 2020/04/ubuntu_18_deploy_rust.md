# [Ubuntu18上部署rust项目](/2020/04/ubuntu_18_deploy_rust.md)

Ubuntu 18.04的云主机上, `cargo install diesel_cli`编译diesel时报错：

```
error: aborting due to previous error

error: failed to compile `diesel_cli v1.4.0`, intermediate artifacts can be found at `/tmp/cargo-installfwJlrU`
```

根据[官方README](https://github.com/diesel-rs/diesel/blob/master/guide_drafts/backend_installation.md#user-content-debianubuntu)
Ubuntu系统要把SQLite、MySQL、PostgreSQL的库安装上才能编译成功(也可按需安装，用到哪个数据库diesel_cli和lib只装对应的就行)

一开始我还错误的以为是rustup安装的cargo和apt安装的cargo有冲突，所有没有证据前不要轻易猜测

---

题外话：

服务器在编译diesel代码时我在刷leetcode的题，正思考🤔链表的代码是怎么是

注意到网上有个create叫leetcode，我以我是leetcode官方给出的，一些特定题目的数据结构库

下载下来后发现只是leetcode其中3到4题左右的题解...

为了不影响我不看他人代码独立做完leetcode的题，固删之