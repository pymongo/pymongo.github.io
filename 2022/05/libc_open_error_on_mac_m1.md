# [S_IRUSR err on M1](/2022/05/libc_open_error_on_mac_m1.md)

```
同事反馈open函数 S_IRUSR flag 在mac M1报错
open("",O_RDONLY,S_IRUSR|S_IWUSR)
我试在aarch64-unknown-linux-musl能编译的
但在mac M1上类型就不一样无法编译

开发的是Linux only的应用所以gitlab CI也没检查苹果能否编译

标准库文件 API 虽能跨平台但缺少 flock 文件锁等封装有时只能调用 C 函数
```

![](/2022/05/libc_open_error_on_mac_m1.png)

<https://twitter.com/ospopen/status/1530405154033258496>

## fedora cross compile

由于 fedora 不知道怎么安装 arm 的 glibc 所以就只能 aarch64 musl 了

(在 archlinux 发行版我记得还是可以安装 arm 的 glibc)

```
# on fedora install gcc-aarch64-linux-gnu not gcc-arm-linux-gnu(32 bit)

#CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++ \
CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-linux-gnu-ld \
CC_aarch64_unknown_linux_musl=aarch64-linux-gnu-gcc \
cargo b --target aarch64-unknown-linux-musl
```
