flowistry 是一个类似 rust-analyzer 的 vscode 插件，主要命令是 Rust 代码数据流分析，函数输出输出影响范围等等

核心代码: <https://github.com/willcrichton/flowistry/blob/2f0f843d46995367bf20f76b43315a7199bca70d/src/core/analysis.rs#L50>

ldd 去看依然是找不到 libstd 动态库

```
[w@ww flowistry]$ ldd ./target/debug/flowistry-driver
        linux-vdso.so.1 (0x00007ffc4333b000)
        librustc_driver-d2cc96ed75437e33.so => not found
        libstd-d6566390077dd5f5.so => not found
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007f0732fba000)
        libpthread.so.0 => /usr/lib/libpthread.so.0 (0x00007f0732f99000)
        libc.so.6 => /usr/lib/libc.so.6 (0x00007f0732dcd000)
        /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007f07333c3000)
[w@ww flowistry]$ ldd ./target/debug/cargo-flowistry
        linux-vdso.so.1 (0x00007ffe90df7000)
        libLLVM-13-rust-1.57.0-nightly.so => not found
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007f37f773d000)
        libpthread.so.0 => /usr/lib/libpthread.so.0 (0x00007f37f771c000)
        libdl.so.2 => /usr/lib/libdl.so.2 (0x00007f37f7715000)
        libc.so.6 => /usr/lib/libc.so.6 (0x00007f37f7549000)
        /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007f37f7d56000)
```
