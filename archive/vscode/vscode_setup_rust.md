# [vscode配置Rust环境](/archive/vscode/vscode_setup_rust.md)

vscode的Rust插件是Rust官方维护的，支持codelen功能(可执行函数附近会有Run/Debug提示，就像IDEA在main()左边会有个绿色的运行按钮)

1. 安装CodeLLDB插件(开启Rust单步调试功能)
2. 修改vscode全局setting.json的ra相关可执行文件路径配置项
3. 编译rust-analyzer(以下简称ra)源码，仅编译ra可执行文件
4. vscode安装ra插件

*注3: 编译ra源码的补充，看源码的`.cargo/config`文件可知通过`cargo xtask install --server`可以仅编译ra可执行文件，不编译安装ra的vscode插件

## vscode的setting.json中ra相关配置

```json
{
    "rust-analyzer.updates.channel": "nightly",
    "rust-analyzer.server.path": "~/.cargo/bin/rust-analyzer",
    "rust-analyzer.cargo.allFeatures": true
}
```

## 为什么不建议用源码编译的dev版ra插件

主要是dev版ra插件会有报错提示:

> Extension 'matklad.rust-analyzer cannot use PROPOSED API

源码编译ra插件需要nodejs环境以及vscode add to path

## 为什么不用官方的Rust插件+rls

1. rls官方维护的不勤快，不支持2021年以后的nightly版本，Rust插件需要rustup额外安装rls和rust-analysis两个component
2. 官方的Rust插件近一年都没更新，不像ra插件频繁维护
3. 同时安装Rust和ra插件时，ra插件会提示冲突you must disable one of them

## code snippet/completion

idea的code_snippet指的是类似idea输入sout能自动生成`System.out.println!("");`这样的代码模板生成或自动补全

也叫[Save as Live Template](https://www.jetbrains.com/webstorm/guide/tips/save-as-live-template/)

部分我认为很有用的代码补全/代码模板生成

| input | generexprte code | require |
|---| ------ | ---- |
| expr.mexprtch | match expr... | expr is enum |
| expr.if | if expr {... | expr is bool |
| expr.ifl | if let... | (ra only)expr is Option/Result |
| expr.dbg | dbg!(expr) |
| expr.dbgr | dbg!(&expr) |
| p | println!("") | (idea only) |
| pd | eprintln!(" = {:?}", ); |
| pdd | eprintln!(" = {:#?}", ); |
| tmod | #\[cfg(test)] mod tests... |
| tfn | #\[test] fn... |
| "{expr}".logi | log::info!("{}", expr) | (ra only) |

*注: `"".`+logd/logw/panic/format等也是类似"".logi的效果

[参考ra源码](https://github.com/rust-analyzer/rust-analyzer/blob/master/crates/completion/src/lib.rs#L29)

## vscode-ra/idea展开声明宏

vscode光标移到宏上，输入command `expand macro`就能在右侧显示声明宏展开后的代码

idea则是alt+enter的code_action里可以展开宏

无论是idea或vscode都不支持过程宏的展开，过程宏展开只能靠cargo expand

![](rust_analyzer_code_snippet_completion.gif)

## Rust趣学指南(有趣的学习资料)

- (入门)rustlings: rustlings watch可以监控exercises文件夹的变化，一共有多个例如编译报错这样练习题，让你逐个修改源文件进行闯关n
- (较难)[rust-quiz](https://dtolnay.github.io/rust-quiz)
- (较难)cppquiz.org

---

总之Rust的开发环境用 vscode+ra 或 idea_ce(社区版)+Rust插件 这两个方案都不错(配置超简单，功能强，开发者频繁维护/迭代)
