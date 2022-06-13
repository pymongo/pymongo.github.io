# [dmesg /dev/kmsg](/2022/05/dmesg_dev_kmsg.md)

容器内的 coredump 默认信息会写到 dmesg 里面，我感觉是自己没有拦截或收集 coredump 的话就会 fallthrough 到 dmesg

我看完了 rust 的 rmesg 源码就是用 rust 重写的 dmesg 可执行文件，其核心内容无非就是读取 /dev/kmsg 文件

```rust
use tokio::io::AsyncBufReadExt;
use tokio::io::BufReader;
let mut dmesg = BufReader::new(tokio::fs::File::open("/dev/kmsg").await.unwrap()).lines();
while let Ok(Some(line)) = dmesg.next_line().await {
```
