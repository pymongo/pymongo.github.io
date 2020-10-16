# [vscode配置Rust开发环境](/2020/10/vscode_setup_rust.md)

我目前只用rust和rust-analyer两个插件，连project的tasks.json和laugh.json都不用设置就能用了codelen

插件安装要有先后顺序(rust依赖rust-analyzer)

1. rust-analyzer
2. CodeLLDB(debugger)
3. rust

## rust-analyer安装

由于rls(rust language server)依赖nightly，建议开发环境rustup default nightly

> rustup component add rls

> rustup component add rust-analysis

由于vscode下载rust-analyzer的链接404了，所以被迫去github上拉源码去编译

```
$ git clone https://github.com/rust-analyzer/rust-analyzer.git && cd rust-analyzer
$ cargo xtask install
```

然后在全局的settings.json中添加`"rust-analyzer.serverPath": "~/.cargo/bin/rust-analyzer",`

===

我对vscode的Rust插件生态还是非常满意的，按照上述安装完后就自动有codelen(也就是在单元测试和main函数上有个Run|Debug的按钮)

vscode的python插件死活都不给出codelen，还要手工写各种json才能一键运行

rust-analyzer基本满足了像Intelij-Rust那样的灰色字提示类型、错误检查

相比intelij-rust, rust-analyzer的优缺点结论:

```
+ 支持非cargo workspace多个Rust子文件夹的检查
+ 支持#!\[feature]等属性宏的自动补全()
- 语法检查很慢，rust-analyzer的CPU/负载很高
- rust-analyzer更新不方便，需要删掉二进制包重新拉代码编译才能更新
```
