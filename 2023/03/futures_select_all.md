# [futures select_all](/2023/03/futures_select_all.md)

模拟一个应用场景，最多 5 个工作线程或者连接池最多五个长连接

select_all 可以同时 await 一个数组的 future，其中一个 Future 完成时，返回 (Future::Output, index, remain)

可以将工作线程的任务或者连接池请求队列看成一个数组，然后滑动宽度为 5 的窗口去执行

```rust
const NUM_WORKERS: usize = 5;
async fn do_job(job_id: usize) -> usize {
    println!("doing job {job_id}");
    if rand::random::<bool>() {
        sleep(Duration::from_secs(1)).await;
    } else {
        sleep(Duration::from_secs(2)).await;
    }
    job_id
}
#[tokio::main]
async fn main() {
    let mut jobs = (0..12).collect::<std::collections::VecDeque<usize>>();
    let mut futs = Vec::new();
    while let Some(job_id) = jobs.pop_front() {
        if futs.len() < NUM_WORKERS {
            futs.push(do_job(job_id).boxed());
            continue;
        }
        let futs_ = std::mem::take(&mut futs);
        let (fut_ret, _index, remain) = futures::future::select_all(futs_).await;
        // println!("done  job {fut_ret}");
        futs = remain;
        futs.push(do_job(job_id).boxed());
    }
}
```

```
当协程退出或 IO 阻塞时主动让出占用的计算资源，供其他 Goroutine 使用，这是典型的协作式调度
但在特定情况下(协程长时间占用计算资源)，runtime 会将其强制中断，让其他 Goroutine 都能有机会得到执行
主要采用协作式调度，而抢占式调度仅在特定情况下作为辅助
```
