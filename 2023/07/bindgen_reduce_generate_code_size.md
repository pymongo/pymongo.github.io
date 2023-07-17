# [bindgen 精简生成代码](/2023/07/bindgen_reduce_generate_code_size.md)

我一个 8000 行的 C++ 头文件结果生成出 4 万的 rust 代码就不合理，而且还有重复的 const 定义

## 精简 1. 只引入一个根节点中心化的 header 文件

代码量从 4w -> 3.5w 没有质变

## 精简 2. 去掉 layout_test 生成

发现生成代码中大量无用的测试， .layout_test(false) 去掉后 3.5w -> 2w 瞬间少了接近一半

但是由于源码中引用了 math.h 导致生成代码中大量 sin, cost 几千行的标准库函数

## 精简 3. 白名单策略过滤掉标准库代码生成

<https://github.com/rust-lang/rust-bindgen/issues/1675>

生成的代码量从 2w -> 8k 跟 8000 行的 C 代码接近同一个数量

```rust
let include_dir = "include";
let mut builder = bindgen::builder()
    .clang_args(["-I", include_dir, "-x", "c++"])
    .header(format!("{include_dir}/db.h"))
    .layout_tests(false)
    .derive_debug(false)
    .derive_copy(false)
    .generate_comments(false);

// skip e.g. math.h
for each in std::fs::read_dir(include_dir).unwrap().flatten() {
    let filename = each.file_name();
    let filename = filename.to_str().unwrap();
    let header_path = format!("{include_dir}/{filename}");
    builder = builder.allowlist_file(header_path);
}
```

巧妙的是，用了白名单之后，先前一直没能解决的 codegen 有重复的 const 定义居然解决了
