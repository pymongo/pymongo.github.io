# [rustyline add cursor shortcuts](/2021/08/rustyline_add_cursor_shortcuts.md)

rustyline 是一个用于像 redis-cli 那样 REPL cli 软件的读取用户输入，有自动补全提示等功能

例如自动补全字体的 ANSI color 可以用 [redis-cli 源码中 hint 的颜色](https://github.com/redis/redis/blob/74590f8345c148024a9d55471409e772d9c8fa90/src/redis-cli.c#L744)

如果是 rustyline Editor 的 Emacs 模式则自动包含光标移动的快捷键，如果是 vi 配置则需要以下快捷键配置:

```rust
// add unix cursor shortcuts(eg. Ctrl+a move cursor to start of line): https://github.com/kkawakam/rustyline/issues/146
editor.bind_sequence(
    KeyEvent::ctrl('a'),
    EventHandler::Simple(Cmd::Move(Movement::BeginningOfLine)),
);
editor.bind_sequence(
    KeyEvent::ctrl('e'),
    EventHandler::Simple(Cmd::Move(Movement::EndOfLine)),
);
editor.bind_sequence(
    KeyEvent::ctrl('f'),
    EventHandler::Simple(Cmd::Move(Movement::ForwardChar(1))),
);
editor.bind_sequence(
    KeyEvent::ctrl('b'),
    EventHandler::Simple(Cmd::Move(Movement::BackwardChar(1))),
);
editor.bind_sequence(
    KeyEvent::alt('f'),
    EventHandler::Simple(Cmd::Move(Movement::ForwardWord(1, At::AfterEnd, Word::Big))),
);
editor.bind_sequence(
    KeyEvent::alt('b'),
    EventHandler::Simple(Cmd::Move(Movement::BackwardWord(1, Word::Big))),
);
```
