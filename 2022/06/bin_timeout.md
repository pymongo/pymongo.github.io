# [/bin/timeout](/2022/06/bin_timeout.md)

rust playground 功能通过 timeout 命令限制用户如死循环的代码从而节省资源

我看了下 rust coreutils 实现里面通过 loop-sleep try_wait(non-blocking wait) 实现的

以为能用上什 tokio 这类的结果也没
