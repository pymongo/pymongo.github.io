# [vscode配置Rust开发环境](/archive/vscode/vscode_setup_rust.md)

vscode的Rust插件是Rust官方维护的，功能非常棒，codelen支持(Run/Debug灰色提示，点一下就能运行代码)就跟IDEA一样方便

插件安装要有先后顺序(rust依赖rust-analyzer)

1. 安装CodeLLDB(开启Rust的debug功能)插件
2. rustup添加所需组件并编译rust-analyzer源码成可执行文件
3. 安装rust-analyzer插件
4. 安装Rust插件

## 1. 编译rust-analyzer源码

由于ra依赖rls，而rls(rust language server)依赖nightly，rustup需要先安装一个nightly版本的Rust

```
rustup default nightly
rustup component add rls
rustup component add rust-analysis
```

git clone完ra源码后，`cat .cargo/config`发现repo提供了一个`cargo xtask install`的命令alias帮助将ra编译成cargo install那样的binary格式

编译完后再去vscode全局的settings.json中添加一行配置手动指定ra二进制文件的路径:

> "rust-analyzer.serverPath": "~/.cargo/bin/rust-analyzer"

然后按照上述步骤2~4即可完成vscode的Rust环境的安装

---

rust-analyzer相比Intellij-rust的优劣势(个人看法):

```
+ 支持非cargo workspace多个Rust子文件夹的检查
+ 支持#!\[feature]等属性宏的自动补全()
- 语法检查很慢，rust-analyzer的CPU/负载很高
- rust-analyzer更新不方便，需要删掉二进制包重新拉代码编译才能更新
```
