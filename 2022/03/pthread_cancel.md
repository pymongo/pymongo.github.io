# [Rust 中止线程](/2022/03/pthread_cancel.md)

tokio 协程可以用 handle.abort() 中止执行，不过标准库线程 spawn 就没有 stop 的方法，得用 Linux glibc 的 API

```rust
use std::os::unix::prelude::JoinHandleExt;
let handle = std::thread::spawn(|| {
    loop {
        unsafe {
            dbg!(libc::time(std::ptr::null_mut()));
            libc::sleep(1);
        }
    }
});
let pthread_t = handle.into_pthread_t();
unsafe {
    // libc::pthread_join(pthread_t, std::ptr::null_mut());
    libc::pthread_cancel(pthread_t);
    libc::pthread_cancel(pthread_t);
    libc::pthread_cancel(pthread_t);
    // libc::pthread_kill(pthread_t, libc::SIGTERM);
}
```
