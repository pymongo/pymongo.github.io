# [浏览器运行Rust编译的wasm](/2020/04/rust_wasm.md)

MDN的wasm教程略为复杂，[reddit有一神贴](https://www.reddit.com/r/rust/comments/9t95fd/howto_setting_up_webassembly_on_stable_rust/)
讲解rust不借助任何extern create或其它lib/cli工具，编译wasm的过程

首先创建一个lib类型的rust项目，Cargo.toml内加上两行指明lib类型：

```
[lib]
crate-type = ["cdylib"]
```

lib.rs中定义一个add函数，以后会在js端去使用这个add函数

```rust
#[no_mangle] // no_mangle可以理解为FFI相关宏，实现Calling Rust code from C
pub extern fn add(a: i32, b: i32) -> i32 { a + b }
```

编译生成的wasm在 `target/wasm32-unknown-unknown/release/$project_name.wasm`

> cargo build --release --target=wasm32-unknown-unknown

我把生成的wasm挪到了项目根目录，源代码在[github上这个仓库](http://baidu.com)

编写index.html，然后通过python3 -m http.server之类的HTTP服务器上运行

```html
<script>
  (async () => {
    await fetch('add.wasm')
      .then(response => response.arrayBuffer())
      .then(bytes => WebAssembly.instantiate(bytes))
      .then(obj => console.log("add result = " + obj.instance.exports.add(1, 1)))
      .catch(error => console.log("error: " + error));
  })();
</script>
```

打开dev tools的console，可以看到输出结果是2

---

如果想用Web API(像window.alert)，还是老老实实用wasm-pack + npm(webpack)吧
