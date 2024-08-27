# [unwrap_or中不要调用函数](/2024/01/do_not_call_function_in_unwrap_or.md)

以前很费解为什么 clippy 老是建议有些 expect/unwrap_or 改成 unwrap_or_else

业务上遇到一个 unwrap_or 里面调用 rest HTTP 请求的代码有副作用，被同事提醒 unwrap_or 不是 Lazy 的 Ok/Err 的分支，所以两个分支都会触发unwrap_or里面的表达式
