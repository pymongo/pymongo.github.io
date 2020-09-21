# Rust最佳实践

## 用env::var还是OnceCell共享全局的String变量?

假设env::var是通过dotenv读配置文件再写入到环境变量中，假设环境变量和OnceCell一样只会被写入一次

```
test bench_env_var   ... bench:         255 ns/iter (+/- 16)
test bench_once_cell ... bench:           1 ns/iter (+/- 0)
```

实验表明，用env::var去共享全局的字符串常量，性能比OnceCell慢两个数量级
