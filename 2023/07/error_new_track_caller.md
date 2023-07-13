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

impl std::fmt::Display for ErrorTrace {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

// conflict impl std::error::Error for ErrorTrace {}
impl<E: std::error::Error + 'static> From<E> for ErrorTrace {
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
        Self {
            message: format!("{file}:{line} {}", message),
            err_code: 51_040_000,
        }
    }
}
```
