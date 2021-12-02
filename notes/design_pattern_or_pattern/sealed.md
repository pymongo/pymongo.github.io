https://github.com/tokio-rs/tracing/blob/63d41707efa98d3ce64be7fff02ee348157a6985/tracing-subscriber/src/lib.rs#L187

https://github.com/ZhangHanDong/real-world-rust-design-pattern/issues/4

`trait Sealed` 其实就是 **non_exhaustive 版本的 trait**

例如库有个 trait 是 A+Sealed 表示库作者不希望库的使用者去 impl A
