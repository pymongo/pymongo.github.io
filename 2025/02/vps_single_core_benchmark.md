# [VPS单核性能测试](/2025/02/vps_single_core_benchmark.md)

> sysbench --test=cpu --cpu-max-prime=20000 run

| CPU         | Events per Second | Avg Latency | P95 Latency | Compile Rust Analyzer | Note            |
|-------------|-------------------|-------------|-------------|-----------------------|------------------|
| 9950X      | 26545             | 0.38        | 0.38        | 40s                   |                  |
| 9274F      | 18599             | 0.54        | 0.56        |                       |                  |
| 13900H     | 17124             | 0.58        | 0.68        | 87s                   | my laptop        |
| 9454P      | 17033             | 0.59        | 0.60        |                       |                  |
| 9R14       | 16776             | 0.60        | 0.61        |                       | aws c7a         |
| 7002       | 16443             | 0.61        | 0.62        |                       | hetzner x86      |
| Neoverse-N1 | 12688             | 0.79        | 0.83        |                       | hetzner arm      |
| 8488C      | 12446             | 0.80        | 0.83        |                       | aws c7i-flex     |


```
cpu,evts_per_sec,avg_latency,p95_latency,compile_rust_analyzer,note
9950X,26545,0.38,0.38,40s,
9274F,18599,0.54,0.56,,
13900H,17124,0.58,0.68,87s,my laptop
9454P,17033,0.59,0.60,,
9R14,16776,0.60,0.61,,aws c7a
7002,16443,0.61,0.62,,hetzner x86
Neoverse-N1,12688,0.79,0.83,,hetzner arm
8488C,12446,0.8,0.83,,aws c7i-flex
```

根据 www.cpubenchmark.net 数据 9274F,5900X,9950X 的单核性能分别是 3373,3470,4744
