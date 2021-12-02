# Rust hardware relative

## CPU micro arch

```
gcc -march=znver3
clang -march=znver3
rustc -C target-cpu=znver3 r.rs

gcc --target-help | grep march -A12
llc --version
```

gcc/rust 默认的 march 都是 x86_64

---

spdk.io 一次上下文切换(内核空间和用户空间)等于一次高速闪存IO

kernel bypass
