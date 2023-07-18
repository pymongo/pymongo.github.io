# [含生命周期的迭代器闭包](/2023/07/iterator_closure_with_lifetime.md)

最近给国产数据库写 sqlx 驱动，sqlx-postgres 源码中数据库查询都用同一个迭代器实现

fetch_all/fetch_one/fetch_optional 其实都用的一个迭代器流实现的

- fetch_one=iter.next().unwrap()
- fetch_optional=iter.next()
- fetch_all/fetch_many=iter.collect()

用 iter 的好处还有例如 .execute 这种修改记录的 DML 操作取一次迭代器就够了

> 当然 sqlx 命名为 QueryResult 我觉得不好会跟 QueryRow 混淆，我的库命名为 DmlResult

异步函数的迭代器业界公认就 futures::Stream 达到类似效果(严格意义的异步迭代器暂不存在)，先把简单点的同步迭代器搞明白先，至少同步函数不至于像异步函数那样传递指针或生命周期有限制，例如只有 &'static 指针才能跨线程 Future

## 返回不确定长度的迭代器闭包

我选择在 sqlx fetch 函数内使用闭包迭代器而非定义结构体实现迭代器再返回，是因为闭包自动捕获闭包所需状态变量，使用更方便且可读性更好。我简化了下我的业务场景让 gpt 实现了如下函数

```
give a rust example, a function return a iter yield 1 every second if current timestamp > 100 break iter
can you replace to panic to return EOF or end the iter
```

```rust
fn delayed_iter() -> impl Iterator<Item = u32> {
    let start_time = SystemTime::now();
    
    (0..).map(move |_| {
        let current_time = SystemTime::now();
        let duration = current_time.duration_since(start_time).unwrap();
        
        if duration.as_secs() > 100 {
            None
        } else {
            thread::sleep(Duration::from_secs(1));
            Some(1)
        }
    }).take_while(|item| item.is_some()).map(|item| item.unwrap())
}
```

我想着继续美化代码去掉 unwrap 结果 gpt 这傻瓜居然把 `.take_while(|item| item.is_some()).map(|item| item.unwrap())` 换 flatten 函数到了 None 之后直接卡住不动逻辑都错了

可能看看标准库的 TcpStream/BufReader 的闭包实现会带给我有更多灵感

UPDATE: 飞书群友提供了 map_while 函数完美替代了 take_while+map

---

## iterator lifetime

我把获取数据库下条记录的循环改成迭代器之后有生命周期报错，毕竟返回一个闭包带有数据库句柄的 ffi 引用，加上生命周期就解决了

> error[E0700]: hidden type for `impl Iterator<Item = sqlx_core::Either<DmlResult, row::Row>>` captures lifetime that does not appear in bounds

## left_future 问题

由于遇到 DML 语句我直接返回了一个类似 stream::once 的 closure 类型与后面的返回不一致，实际上迭代器输出内容是一样的

```
 note: expected struct `std::iter::Map<std::ops::Range<{integer}>, [closure@src/tydb_connection.rs:472:35: 472:43]>`
          found struct `Map<TakeWhile<Map<RangeFrom<{integer}>,    [closure@tydb_connection.rs:510:19]>, ...>, ...>`
```

又是经典的 BoxFuture/left_future 问题，函数签名从 impl 改成 Box 即可

## dyn Iterator not Send

毕竟 sqlx 的所有 trait 基本是异步的涉及跨线程问题，好吧给返回迭代器的函数加上 Send 签名

结果又提示闭包 move 了 *mut 裸指针不能 Send

一顿操作下来给裸指针包一层实现 Send 总算不报错了

包装个类型结构体实现迭代器不方便的是，因为 DQL 语句和 DML 语句的迭代器需要的状态变量都不相同，要实现两个结构体的迭代器，用闭包返回迭代器就方便很多

最终我 sqlx 查询迭代器的函数签名是

```rust
pub unsafe fn fetch_iter<'a>(
    &'a mut self,
    sql: &'a str,
    args_opt: Option<Args>,
) -> Box<dyn Iterator<Item = Result<Either<DmlResult, Row>, sqlx_core::Error>> + Send + 'a>
{
    let sql = format!("{sql}\0");
    KCIStmtPrepare(
        self.stmt,
        self.err,
        sql.as_ptr(),
        sql.len() as _,
        KCI_NTV_SYNTAX,
        KCI_DEFAULT,
    )
    .has_err(self.err);
    match stmt.sql_type as u32 {
        KCI_STMT_SELECT => {}
        KCI_STMT_UPDATE => {
            let updated_rows = stmt.updt_num;
            return Box::new((0..1).map(move |_| Ok(Either::Left(DmlResult(updated_rows)))));
        }
        _ => unreachable!(),
    }
    // ...
}
```

## 同步迭代器转异步

我看 sqlx 基本也是伪异步并没有用 epoll 之类操作系统异步 API

而且把 ffi 丢到一个工作线程去串行执行，异步函数用 channel 发命令到工作线程，工作线程执行完再通过 oneshot 通知已经完成

tokio oneshot 需要两端都是异步所以 sqlx 用的 flume

这么是不阻塞 tokio worker thread, 但
