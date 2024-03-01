# [tokio interval问题](/2024/02/tokio_time_interval_problem.md)

最近发现一个问题 tokio::time::interval 例如 1s 间隔

如果 60s 内因为程序卡死或者执行耗时操作都没有进行 await/poll 则接下来 60 次 tick().await 都会瞬间返回
