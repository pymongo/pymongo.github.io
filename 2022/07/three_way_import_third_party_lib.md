# [第三方库的三种引入](/2022/07/three_way_import_third_party_lib.md)

## system wide

C/C++ 生态常用，经常用系统的包管理器装一个例如 python-devel 或 python3-devel 的包，

然后动态库放在 /usr/lib 对应的头文件放在 /usr/include

使用的时候用 where, pkg-config 等工具去找包，gcc 加个 -l 参数编译链接包

举例: libcrypto.so, boost, pip

## project wide

很显然这种是主流且最简单容易跨平台+多版本等等，热门编程语言全都采用这种方案，提供包管理工具管理项目的第三方库清单

用户 HOME 目录下有个中心化的文件夹缓存同一个包用过的多个版本，每个项目可以指定不同版本的包

举例: maven($HOME/.m2), cargo, npm, bundle(ruby)

## project vendor

第三方库源码放进项目 code base 中一起编译

如果第三方库代码量少且自己有 patch 的需要，可以 vendor 进来避免国内访问 git 过慢难以更新代码

举例: go vendor(无 go mod 前), rust-rocksdb, openssl-sys(vendor feature)
