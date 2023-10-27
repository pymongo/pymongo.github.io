# [#[track_caller]](/2023/07/error_new_track_caller.md)

保存错误 ? 上抛的上下文方便定位错误，Rust 记录错误上抛位置的方法有很多种

1. std::backtrace (实际上调用 backtrace crate)
2. 用宏创建错误夹杂 file!() line!() 信息
3. #[trace_caller]: Pass the parent call location to std::panic::Location::caller()
4. Error::source 或 anyhow/thiserror 自己的 context

backtrace 的好处是记录了错误的传递和调用栈，但依赖 debug symbol 且 capture/unwind stack 的过程有不小性能开销损失

我试了个函数很多 318M 左右的 release build binary 去掉 `debug=true` 重新编译后就剩 48M

```rust
// -C debug-prefix-map=`pwd`=.
const PWD: &str = env!("PWD");
// const REGISTRY_HOME: &str = const_str::concat!(env!("CARGO_HOME"), "/registry/src/");

pub fn backtrace_capture() -> Vec<String> {
    let mut frames = Vec::new();
    backtrace::trace(|frame| {
        backtrace::resolve_frame(frame, |symbol| {
            if let Some(line) = (|| {
                let filename = symbol.filename()?.to_str()?;
                if filename.starts_with("/rustc") {
                    return None;
                }
                let filename = if let Some(x) = filename.strip_prefix(PWD) {
                    x
                } else if let Some(x) = filename.strip_prefix(env!("HOME")) {
                    x
                } else {
                    filename
                };
                Some(format!(
                    "{filename}:{}",
                    symbol.lineno().unwrap_or_default()
                ))
            })() {
                frames.push(line);
            }
        });

        frames.len() <= 10
    });
    frames
}
```

其实记录下问号或者错误抛出的位置也够了，通过 ra 的 show call hierarchy 也能找出可能的调用栈，再结合上下文也能找出准确调用栈

```rust
#[derive(Debug)]
pub struct Error(String);

impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

// conflict impl std::error::Error for ErrorTrace {}
impl<E: std::error::Error + 'static> From<E> for Error {
    #[track_caller]
    fn from(err: E) -> Self {
        Self::new(&err.to_string())
    }
}

impl Error {
    #[track_caller]
    pub fn new(message: &str) -> Self {
        let location = std::panic::Location::caller();
        let file = location
            .file()
            .trim_start_matches(env!("PWD"))
            .trim_start_matches(env!("HOME"));
        let line = location.line();
        Self(format!("{file}:{line} {}", message))
    }
}
```

---

再次想起关 debug symbol 318->44M 的惊人变化，感觉 debug symbol 还是默认关闭需要调试再开好点，看看 gpt 怎么说

```
Rust debug symbols provide valuable information during the debugging process. Here are some of their uses:

Symbolic stack traces: Debug symbols allow the generation of symbolic stack traces, which provide more meaningful information about the sequence of function calls leading up to a particular point of execution. This aids in understanding the flow of code and identifying the source of bugs or crashes.

Variable inspection: With debug symbols enabled, debuggers can display and inspect the values of variables at different points in your program's execution. This helps in tracking down issues related to incorrect variable values or unexpected behavior.

Crash analysis: When an application crashes, debug symbols assist in generating crash reports that contain meaningful function names and line numbers instead of just memory addresses. This allows for easier identification of the exact location where the crash occurred.

Backtrace analysis: Debug symbols are crucial for generating backtraces, which show the call stack leading up to an error or exception. Backtraces help identify the sequence of function calls and understand the context in which an error occurred.

Dynamic analysis: Tools like profilers and performance analyzers utilize debug symbols to map performance data to specific functions, enabling developers to optimize code by identifying hotspots and bottlenecks.

It's important to note that debug symbols should generally be used during development and testing. For production releases, it's common to disable debug symbols to reduce binary size and improve performance.
```

```
https://twitter.com/ospopen/status/1679472362843164673
300M的release build去掉debug=1重编后变小成50M,
debug symbol常用于gdb或anyhow error backtrace

用std::backtrace记录错误上抛调用栈导致binary size变大好几倍了
其实只记录错误上抛位置的行号，再用vscode call hierarchy找完整调用栈
用track_caller自动在错误转换上抛前记录行号 不需要错误宏
```

---

## update from 23/10/19
track_caller 无法在 async_trait 生效
