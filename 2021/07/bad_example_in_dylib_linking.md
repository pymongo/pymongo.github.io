# [错误绑定dylib的例子](2021/07/bad_example_in_dylib_linking.md)

看了 [Target auto-discovery](https://doc.rust-lang.org/cargo/reference/cargo-targets.html#target-auto-discovery)

我以为 build.rs 能写在这么写在子文件夹中:

```
examples/
├── bad_dylib_link
│   ├── build.rs
│   └── main.rs
```

实际上通过 env! 宏随便测试一下都知道上述写法中 build.rs 是不生效的(虽然 ra 也不会报错)

---

## 使用 link(name 的好处

```rust
#[link(name = "readline", kind = "dylib")]
extern "C" {
    static rl_readline_version: libc::c_int;
}
```

例如上述代码哪怕没在 build.rs 中 link libreadline.so

编译时也能根据 link 自动找到库名去链接，这要避免了开发人员漏写 build.rs 也精简了代码

而且还提高了可读性，一看就知道是从函数名或全局变量是从哪一个动态库来的

但这只针对单个 so 文件绑定比较简单而且规范的库

像是 gdbm 这种库多个函数分布在两个不同的 so 文件，还是老老实实在 build.rs 中 link 吧
