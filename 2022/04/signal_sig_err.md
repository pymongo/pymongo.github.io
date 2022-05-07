# [libc::SIGERR](/2022/04/signal_sig_err.md)

一般系统调用返回负数或者负一表示报错，返回正整数都算成功(例如返回一个 fd)

今天才发现 signal 函数返回的是替换前的信号回调函数指针，只有返回 SIGERR 才是出错，其余情况哪怕返回负数也是正常的

<https://twitter.com/ospopen/status/1518584248487510016>

犯错了以为 signal 函数跟大部分系统调用一样返回 0 才表示正常所以我写 if syscall_resp != 0 就 panic!
在 5.10 内核我开发机上跑没问题，结果到 4.18 的 centos8 image 中跑就 panic

再仔细看 man 文档说的是返回值是该信号的上个回调函数的函数指针，如果返回 libc::SIG_ERR 才表示错误
