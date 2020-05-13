# [Go/Rust语言工具介绍](/2020/05/go_rust_toolchain.md)~~

更新rust语言工具链时发现一些实用的工具，发现很多Rust的工具其实Go语言也有。

## go fmt

gofmt或go fmt是用来格式化代码的

当我尝试使用`go fmt`命令时得到报错的提示：`can't load package...`

我也很困扰，至今都没搞懂go的包管理和package引用，只能通过`go fmt src/app/main.go`格式化单个文件

还是Rust更香，`cargo fmt`直接格式化整个项目文件夹内的所有rust文件，简单粗暴

## cargo clippy

类似eslint、gradle lint，检查代码质量的工具

go似乎没有自带lint工具，rust的clippy真实用，指出我项目中好几段丑陋的代码

## go env

用于打印环境变量，rust没有这个工具，rust要通过代码打印环境变量：

```rust
for (key, value) in std::env::vars() {
    println!("{}: {}", key, value);
}
```

## evcxr(REPL)

goland上似乎没有提供REPL的工具，rust的evcxr用起来还不错，是intelij-rust推荐下我猜知道有这个工具

## go tool pprof

[踩坑记： go 服务内存暴涨](https://www.v2ex.com/t/666257)
