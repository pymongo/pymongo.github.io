# [no_std中实现printf](/2020/11/impl_printf_in_no_std.md)

我最近看了Rust标准库的println!宏的源码，发现最底层是unistd.h的write系统调用，写入到STDOUT文件描述符

虽然标准库内部大量使用了libc的源码，不知道为什么不集成到core里，所以我想在no_std内实现print方法就被迫引入唯一一个"第三方"库libc

```rust
#[no_std]

fn print(bytes: &[u8]) {
    const STDOUT: i32 = 1;
    let bytes_c_void_ptr = bytes.as_ptr() as *const core::ffi::c_void;
    unsafe {
        // system call `ssize_t write(int fd, const void *buf, size_t count);` in `unistd.h`
        let write_len = libc::write(STDOUT, bytes_c_void_ptr, bytes.len());
        assert_eq!(write_len, bytes.len() as isize);
    }
}

fn main() {
    print(b"Hello World!\n");
}
```

```c++
#include <unistd.h> // write
#include <string.h> // strlen
#include <assert.h> // assert

int main() {
    const char* text = "Hello World\n";
    ssize_t write_len = write(1, text, strlen(text));
    assert(write_len == strlen(text));
    return 0;
}
```

以下是通过time工具对比mac的gcc和Rust分别进行write系统调用的性能对比

```
time cargo run --release  0.01s user 0.01s system 85% cpu 0.029 total
time ./a.out  0.00s user 0.00s system 61% cpu 0.003 total
```

可见Rust的系统调用相比于C语言来说并不是zero cost，会有例如panic_handler这样额外的overhead

leetcode上没涉及系统调用还好，codeforces上Rust题解由于设计read和write系统调用会比C语言慢

所以leetcode上Rust比C语言快是个特例，我试了下1u64到1000000u64之和，结果Rust运行速度只有C语言的1/4
