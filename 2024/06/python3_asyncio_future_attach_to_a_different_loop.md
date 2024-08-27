# [asyncio diff loop](/2024/06/python3_asyncio_future_attach_to_a_different_loop.md)

asyncio.create_task 类似于 tokio::spawn, 我在并发执行了几个 task

task 里代码很简单就 `async with lock: asyncio.sleep` 就报错了

> Future attached to a different loop

但去掉 asyncio.sleep 也就是 async with 异步闭包内没有异步await就没事

看了下业务代码 ws线程是一个uvloop 然后策略线程是另一个uvloop 可能出现潜在的跨runtime问题

asyncio这loop各种运行时报错类似于tokio runtime各种类似的运行时panic

```
not running in a tokio runtime
can't create runtime inside a runtime
can't drop runtime...
```


python3 asyncio 遇到报错 Future attached to a different loop

解决办法是去掉async with lock里面的asyncio.sleep(去掉所有await)就不报错了

奇怪asyncio.Lock和asyncio.sleep居然用的是两个不同的event loop

asyncio loop这各种运行时报错 让我联想到tokio runtime也是类似的运行时panic

not running in a tokio runtime
can't create runtime inside a runtime
can't drop runtime...
