# [Rust 实现 tail -f](/2023/07/impl_tail_follow_in_rust.md)

最近在做一个 tail -f 流式读取例如 /var/log/nginx.log 文件的内容再 SSE 返回给前端

虽然 sys/inotify.h 可以 watch 文件改动但有些文件系统例如 NFS 不支持，我看 gpt 给了一个轮询版本的

```cpp
fseek(file, 0, SEEK_END);
current_size = ftell(file);
while (1) {
    fseek(file, 0, SEEK_END);
    file_size = ftell(file);

    // If the file size has increased, read the new data
    if (file_size > current_size) {
        read_size = file_size - current_size;
        fseek(file, -read_size, SEEK_END);
        fread(buffer, sizeof(char), read_size, file);

        // Print the new data
        printf("%.*s", (int)read_size, buffer);

        // Update the current file size
        current_size = file_size;
    }

    // Sleep for a short duration before checking for new data
    usleep(10000); // 10 milliseconds
}
```

大致思路就记录上次文件已读长度，轮询用 SEEK_END 和 ftell 获取最新的文件长度，如果发现文件有新内容就 fseek 到文件新内容部分一直读到尾

查了下 Rust 没有 ftell 但 SeekFrom 更像是缝合了 fseek 和 ftell 于是我参考 fseek 作出以下实现

```rust
use std::io::SeekFrom;
use tokio::io::AsyncReadExt;
use tokio::io::AsyncSeekExt;
let mut file = tokio::fs::File::open("/var/log/nginx.log").await.unwrap();
let mut current_size = file.seek(SeekFrom::End(0)).await.unwrap();
loop {
    let file_size = file.seek(SeekFrom::End(0)).await.unwrap();
    if file_size <= current_size {
        continue;
    }
    let need_to_read_size = file_size - current_size;
    file.seek(SeekFrom::End(-(need_to_read_size as i64)))
        .await
        .unwrap();
    let mut buf = vec![0; need_to_read_size as usize];
    file.read(&mut buf).await.unwrap();
    print!("{}", String::from_utf8_lossy(&buf));

    current_size = file_size;
    tokio::time::sleep(std::time::Duration::from_millis(100)).await;
}
```

Rust 文档说 It is possible to seek beyond the end of file

SEEK_START 作基准时候传入的偏移只能是正整数防止读文件越界，不太理解为何 SEEK_END 的时候还能往后偏移
