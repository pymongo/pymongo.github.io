# [解决 aur 包 gpg no name 错误](/2021/05/aur_gpg_keyserver_no_name.md)

最近在新配的台式机安装 mongodb-bin 时出现gpg报错

原因是 mongodb-bin 依赖的 aur 包 libopenssl-1.0 安装时报错:

> gpg: keyserver receive failed: No name

经同事指点`No name`很可能是DNS解析失败的原因

让我复制上openssl的PGP key单独跑一遍gpg

这里我们选用的是ubuntu的keyserver

> gpg --keyserver keyserver.ubuntu.com --recv-keys 27EDEAF22F3ABCEB50DB9A125CC908FDB71E12C2

Reference: <https://forum.manjaro.org/t/gpg-keyserver-receive-failed-no-name/17849>
