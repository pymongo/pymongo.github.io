
## mongodb UnitTest

```rust
#[tokio::test]
async fn test() {
    let uri = "mongodb://igb:igb@127.0.0.1:27017";
    let db = mongodb::Client::with_uri_str(&uri)
        .await
        .unwrap()
        .database("fpweb");
    update_password(
        "5fc9c2b100cf425100ace78f".to_string(),
        "$3b$12$RnqcyXPrE6DqBZ5I.4YMbuVyn.i.CbfBXRN2bbBesiFOUQSHBfWny".to_string(),
        // "vjiuhjg984792g5".to_string(),
        &db,
    )
    .await
    .unwrap();
}
```

数据库放NVMe分区，每个App的进程都会创建一个同名的Linux用户(类似nginx)，例如api_server进程只有api_server可执行文件的权限，
从用户权限上对应用进程的文件访问/系统资源做限制，systemd限制日志大小，服务端控制客户端，接口返回Lua代码实现客户端热更新

请你搞清楚Linux内核空间和用户空间的async, non-blocking的IO模型，请问tokio和io_uring,aio分别属于什么IO模型？
blocking/non-blocking sync/async
blocking: 用户态/用户空间(User-Mode)通过系统调用向内核空间(Kernel-Mode)请求IO操作时，操作系统会把用户线程挂起，直到操作系统将IO操作完成(软中断)
non-blocking:
Linux OS: 宏内核操作系统，重内核
tokio: 用户空间的异步IO
云存储-边缘计算

---

《Programming Rust》的preface部分强烈建议看本书的同时做一个系统编程领域的项目，
书中列出的os/db方向对我来说太难了，我挑了个难度适合我的media_processing方向，
打算做个类似exiftool/ffmpeg这样的工具
