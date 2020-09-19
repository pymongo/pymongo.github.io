# Rust最佳实践

## 用env::var还是OnceCell共享全局的String变量?

假设env::var是通过dotenv读配置文件再写入到环境变量中，假设环境变量和OnceCell一样只会被写入一次
