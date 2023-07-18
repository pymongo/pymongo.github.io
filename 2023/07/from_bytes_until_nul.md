# [from_bytes_until_nul](/2023/07/from_bytes_until_nul.md)

对于 C++ string 可以用 generate_cstr 也就是 CStr 去映射

对于 char* 的字符串，只是打印的话可以简单使用 libc::perror 或者 libc::printf

最近用 CStr::from_bytes_with_nul 时遇到报错 `FromBytesWithNulError::interior_nul`

查看文档才知道，针对字符串结尾的 '\0' nul byte 个数，如果确定只有一个 nul_byte 则可以用 unchecked 版本的 from_bytes_with_nul

如果是 libc::gethostname 这样 Rust 这边 new 一个 [0u8; 256] buffer 传入给 C

很可能字符串只填充到 buffer 的前 10 个 byte 后面全是 nul byte

这时候用 from_bytes_until_nul 去解析效果等同于用 libc::strlen 获取字符串长度后分割 slice 进行 from_bytes_with_nul_unchecked
