# [glommio io_uring runtime](/2021/06/glommio_io_uring_runtime.md)

由于tokio-uring依然处于RFC草案编辑阶段，想用tokio的io_uring至少还要等几年

于是我想尝试社区推荐的基于io_uring的异步运行时glommio

然而运行glommio示例时就panic了:

> error: The memlock resource limit is too low: 65536 (recommended 524288)

只好修改 `sudo vim /etc/security/limits.conf` 加上以下两行(默认的memlock大小限制64kB)

```
w soft memlock 512
w hard memlock 512
```

修改`limits.conf`的教程在glommio的README的`## What is Glommio?`部分有介绍

注意要重启/重新登陆后才能生效，重启后通过`ulimit`检查是否修改成功

```
[w@ww ~]$ ulimit -a | grep "locked memory"
max locked memory           (kbytes, -l) 512
```

## 测试是否兼容tokio

因为hyper有这个API `with_executor`可以设置非tokio的异步运行时，所以示例中能用hyper作为RESTFUL API服务器

以下是我测试tokio生态的mongodb的代码:

```rust
fn main() {
    let handle = glommio::LocalExecutorBuilder::new()
        .spawn(|| async move {
            let mongodb_client = mongodb::Client::with_uri_str("mongodb://127.0.0.1:27017")
                .await
                .unwrap();
            let db_ping_response = mongodb_client
                .database("test")
                .run_command(mongodb::bson::doc! { "ping": 1_f64 }, None)
                .await
                .unwrap();
            assert!((db_ping_response.get_f64("ok").unwrap() - 1_f64).abs() < f64::EPSILON);
        })
        .unwrap();
    // 注意glommio::LocalExecutor要join之后才能运行
    handle.join().unwrap();
}
```

果然`panicked at 'there is no reactor running, must be called from the context of a Tokio 1.x runtime'`

所以我项目中想用glommio替代tokio还是很难，除非自己fork一份mongodb的代码加上一个类似hyper with_executor的API

## Rust io_uring生态的其它库

希望能像tokio那样支持 await_timeout, sleep, interval 等等计时器相关API

### ritsu

- repo: <https://github.com/quininer/ritsu> 
- depend_on: tokio-rs/io-uring
- timer_api: sleep

§ 技术选型不选用的理由: 由于不知道tokio的io_uring::types::Timespec要怎么构造，而且用起来要传入handler，不算方便

### rio + extreme

- repo: <https://github.com/spacejam/rio>
- depend_on: libc, libc::syscall, extreme

extreme是一个只用40行实现的async executor，比官方的async_book的executor示例还要简单

rio 的优点是仅依赖libc，而extreme这个极简的异步运行时也只依赖标准库，所以编译非常快

§ 技术选型不选用的理由: 没有 sleep 之类的 timer 相关 API




## 2021-06-27 直播主题

- [] 将旧的tokio websocket聊天改的简单点，方便单元测试
- [] 写一个简单的WebSocket性能测试
