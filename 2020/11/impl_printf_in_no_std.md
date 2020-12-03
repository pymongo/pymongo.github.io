# [no_std中实现printf](/2020/11/impl_printf_in_no_std.md)

我最近看了Rust标准库的println!宏的源码，发现最底层是unistd.h的write系统调用，写入到STDOUT文件描述符

虽然标准库内部大量使用了libc的源码，不知道为什么不集成到core里，所以我想在no_std内实现print方法就被迫引入唯一一个"第三方"库libc

完整源码及测试代码: https://github.com/pymongo/impl_println_in_no_std

实现代码我参考了`libc-print`这个crate的源码，注意no_std环境下的libc库要把std feature关掉

```rust
#![no_std]
use core::fmt::Write;

pub struct StdoutWriter;

impl core::fmt::Write for StdoutWriter {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        const STDOUT_FD: libc::c_int = 1;
        unsafe {
            libc::write(STDOUT_FD, s.as_ptr() as *const core::ffi::c_void, s.len());
        }
        Ok(())
    }
}

impl StdoutWriter {
    #[inline]
    pub fn write_fmt_helper(&mut self, args: core::fmt::Arguments) {
        core::fmt::Write::write_fmt(self, args).unwrap()
    }

    #[inline]
    pub fn write_str_helper(&mut self, s: &str) {
        self.write_str(s).unwrap()
    }
}

#[macro_export]
macro_rules! my_println {
    () => { $crate::my_println!("") };
    ($($arg:tt)*) => {
        {
            let mut writer = $crate::StdoutWriter;
            writer.write_fmt_helper(format_args!($($arg)*));
            writer.write_str_helper("\n");
        }
    };
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
