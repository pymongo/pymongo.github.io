# [Rust2018新增的mod文件夹写法](/2020/11/rust_2018_folder_module_mount.md)

张汉东老师在极客时间上的Rust课程[23 | Rust语法面面观：模块](https://time.geekbang.org/course/detail/100060601-304936?code=pdxuSubY-SyhEcmE8ylWWK-t5YxJF2XB%2Fa3rz-vmsX4%3D)

中提到了Rust 2018中关于文件模块的新写法，以下是我整理的笔记

以下是文件结构，2018的写法中models内没有mod.rs，但是models文件夹同层会有一个models.rs

```
.
├── Cargo.lock
├── Cargo.toml
└── src
    ├── main.rs
    ├── models
    │   └── user.rs
    └── models.rs

main.rs: `mod models;`
models.rs: `pub mod user;`
models/user.rs: `pub fn users_count() -> u32 {10}`
```

其实我更喜欢老的写法，一个文件夹内只要有个mod.rs就说明这是个模块文件夹

新的写法有些「歧义」，如果只有models.rs，还需要看是否有同名文件夹才能得知这个models.rs是不是一个"文件夹"
