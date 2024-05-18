# [第一次rustc提PR](/2024/05/rustc_pr_125004.md)

无意发现了rustc一个ICE nightly切到stable还是ICE，info!宏中复现的换成几十行的最小复现例子(跟公司业务脱敏的代码)也能复现，于是提了 [issue#125004](https://github.com/rust-lang/rust/issues/125002)

rust社区热心网友很快给出了一个minimal reproduce的case `println!("%10000",1)` 看了下rustc源码修这个错误不难于是准备开干！

## unset RUSTUP_DIST_SERVER
发现 x.py 下载 beta 版本编译器的路径用 rsproxy 代理的话会下载成 nightly 版本导致md5不对只好去掉rsproxy环境变量

## 嫌编译太慢 改profile
我把release的opt改成0结果编译stage1的标准库的时候直接死循环卡死...

## ra只跑一次就够了
复制 /root/rust/src/etc/rust_analyzer_settings.json 配置到 rust/.vscode/settings.json

等ra x.py check完之后有缓存就能代码跳转，我之后就把 checkCommand 改成 /usr/bin/true

不然改点代码增量编译都在转圈圈checking, 跑 `"command": "./x.py test tests/ui --test-args format_panic"` 就慢死了

## ./x.py test tidy
我看PR的第一次CI失败了，原因如下，看来 issue-125002.rs 这样的单元测试文件是不合规范的

```
tidy error: file `tests/ui/macros/issue-125002.rs` must begin with a descriptive name, consider `{reason}-issue-125002.rs`
tidy error: /checkout/tests/ui/macros/issue-125002.rs: missing trailing newline
```

## 'tidy' is not installed

./x.py build src/tools/tidy

## doctest fail

Couldn't create directory for doctest executables: Permission denied (os error 13)

> ./x.py test tests/rustdoc-ui/issues --test-args issue-98690

eprintln!("Couldn't create directory for doctest executables: {err} {}", path.display());

## review requests for change

resolve 完 reviewer 建议的改动后，我参考了 https://github.com/rust-lang/rust/pull/125080 这个国人的PR

原来 @rustbot ready 就可以将 PR 状态改回 waiting for reviewer
