# [rustup install rust-analyzer](/2021/04/rustup_install_rust_analyzer.md)

rust-analyzer(以下简称ra)文档上对 rustup安装rust-analyzer只有短短一行说明

> rustup component add rust-analyzer-preview

我看了这个[issue](https://github.com/rust-lang/rustup/issues/2411)
才知道ra可执行文件装到以下路径:

> ~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer

rustup安装ra有几点好处:

1. 作为一个rustup component方便管理
2. ra能跟随rustc一起更新
3. 可以同时拥有多个版本的ra

## rustup进行ra版本切换示例

例如我想制定用2021-04-12版本的ra

> rustup run nightly-2021-04-12 rust-analyzer

虽然toolchain是04-12版本，但是实际上ra会用距离04-12最近的一个stable release也就是ra的04-05版本
djtt