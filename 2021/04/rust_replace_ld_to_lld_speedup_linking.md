# [rust加快编译速度](/2021/04/rust_replace_ld_to_lld_speedup_linking.md)

最近有网友在Rust众的tg群吐槽rust随便改几行都要编译十几秒，网友[图波列夫图160重型超音速可变后掠翼战略轰炸猫猫！](https://twitter.com/wayslog)
给出的建议是把默认的gcc的ld换成llvm的lld

我试了下像修改源码几行这种只需增量编译一个crate,但需要重新linking相关object的场景，确实90%的时间都花在linking上

我试着把ld换成lld之后结果增量编译从十几秒加快到几秒，感谢网友的分享！

## lld的安装配置的相关资料

- [Rust最佳实战篇 - slides](https://docs.google.com/presentation/d/1UB5Uid1zNMaX4XCaYHamq9r0_6imxbHXW0Yoip4cl8E/edit#slide=id.gca30593049_1_16)
- [The Rust Performance Book](https://nnethercote.github.io/perf-book/compile-times.html#linking)
- [bevy book](https://bevyengine.org/learn/book/getting-started/setup/#enable-fast-compiles-optional)
- <https://github.com/bevyengine/bevy/blob/main/.cargo/config_fast_builds>

mac不支持lld可以用类似的zld

linux可以直接装lld也可以`rustup component add llvm-tools-preview`+`cargo binutlis`获取`rust-lld`可执行文件再写个软链接把rust-lld改名成lld

## 不能将全局的~/.cargo/config配置成lld

如果将全局的cargo配置`~/.cargo/config`配置成lld，那rust-analyzer会卡死在`Index 0 of xxx`

## 适用于linux的加速编译配置

```toml
# https://github.com/bevyengine/bevy/blob/main/.cargo/config_fast_builds
[target.x86_64-unknown-linux-gnu]
linker = "/usr/bin/clang"
rustflags = ["-C", "link-arg=-fuse-ld=lld", "-Zshare-generics=y"]

[build]
rustc-wrapper = "/home/w/.cargo/bin/sccache"

[profile.dev]
split-debuginfo = "unpacked"

[profile.test]
split-debuginfo = "unpacked"
```

## 加快增量编译的测试

我们知道增量编译时可能只有一个crate的改动，所以80%-90%的时间都在link executable很正常，慢的是linking的时间

试了个370个crate的项目，单元测试内仅一行`let a=1;`，修改a的值要增量编译一个crate,link两个object

不用lld耗时16秒，用lld耗时8秒，频繁修改单元测试用例或增量编译时，lld的编译速度能快一倍

## 测试全新编译async-graphql

测试机器honorbook pro amd 4600H款，rustc nightly-2021-04-24，async-graphql 源码 2.8.4

所谓全新编译就是 cargo clean 后 cargo build，下面对比编译时间

1. 使用默认的gcc ld: 1m 00s
2. 1的基础上ld换成lld优化: 40.32s
3. 2的基础上加上`linker="/usr/bin/clang"`优化: 40.24s
4. 3的基础上加上`-Zshare-generics=y`优化: 41.62s
5. 4的基础上加上`split-debuginfo="unpacked"`优化: 42.42s
6. 5的基础上加上`sccache`优化: 41.33s

小结: 也就ld换成lld能有巨大的编译速度提升，增量编译1个crate时甚至能有100%的提升，其它优化选项几乎没有任何性能提升

又测试了一个230个crate左右的服务器项目，用去掉除lld以外的优化配置文件，结果编译耗时从45s增加到58秒

所以看上去`linker="/usr/bin/clang"`和`sccache`几乎没用

## sccache编译期缓存并不能加快编译

所以完全没必要加上sccache的编译期缓存工具

## 最终版的linux编译加快配置

```toml
[target.x86_64-unknown-linux-gnu]
rustflags = ["-Clink-arg=-fuse-ld=lld", "-Zshare-generics=y"]

[profile.dev]
split-debuginfo = "unpacked"

[profile.test]
split-debuginfo = "unpacked"
```
