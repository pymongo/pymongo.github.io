# [into_raw_fd](/2022/06/into_raw_fd.md)

Rust 的 Process API 设计以及 fd 所有权设计导致 merge stdout to stderr 变得很难

不如 Java 的 ProcessBuilder.redirectErrorStream(true) 那样简单

Stdio 可以 `From<File>` 但会消耗所有权，因此同一个 File 不能既当做 stdout 又当作 stderr

```rust
use std::os::unix::prelude::FromRawFd;
use std::process::Stdio;
let log_file = std::fs::OpenOptions::new()
    .write(true)
    .create(true)
    .append(true)
    .open("/var/log/app.log")
    .unwrap();
let log_file_fd = std::os::unix::prelude::IntoRawFd::into_raw_fd(log_file);
let mut cmd = std::process::Command::new("app");
cmd.stdin(Stdio::null())
    .stdout(unsafe { Stdio::from_raw_fd(log_file_fd) })
    .stderr(unsafe { Stdio::from_raw_fd(log_file_fd) });
debug!("cmd = {cmd:?}");
cmd.spawn().unwrap();
```

这时候想要 merge stderr to stdout 只能用 unsafe 的 Stdio::from_raw_fd

## 为啥不能用 as_raw_fd

语意上 File::into_raw_fd 跟 Stdio::from_raw_fd 一一对应上

然后在 fd 通过 fork 传入子进程后，因为 File 默认打开参数都有 O_CLOSEXEC 所以 parent process 会自动关闭 fd

用了 into_raw_fd 之后就告诉编译器后续我会自行关闭 fd 而用 as_raw_fd 在 File 析构的时候还是会调一次 close 会有 double close 的安全问题

## daemon process 给子进程开日志文件

由于 File 默认 O_CLOSEXEC 的特点，所以用 daemon process 给应用进程做 reload/restart 的时候，

每次都要重新 open 一次 log file 作为子进程 log fd 通过 Stdio::from_raw_fd 传入
