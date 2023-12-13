# [Criterion bench](/2023/12/criterion_benchmark.md)

默认的cargo bench框架难以实现画个直方图看看、看看性能有没有regression这样的需求，Criterion在社区挺火的能存储多次bench测试结果分析有没有性能倒退生成一个html报告等等

不过用之前有点麻烦，要在Cargo.toml中指定哪个bench文件要禁用掉默认的bench框架加上`harness = false`

```
[[bench]]
name = "my_benchmark"
harness = false

# 貌似以下办法也行
[lib]
bench = false
```

由于公司开发机只有WSL环境的linux，跟实际的aws linux云主机有差异，因此还是希望编译成一个 binary scp 到云主机真实环境测试

例如有 `benches/foo.rs` 文件，cargo bench --bench foo 的时候看到日志

> Running benches/foo.rs (target/release/deps/foo-c4d17751adf35351)

这个可执行文件运行时需要 **吃掉一个--bench入参** 所以要喂一个入参

> ./target/release/deps/foo-c4d17751adf35351 --bench

我不太喜欢 criterion 宏太多了都不知道有哪些可以配置的参数，宏展开后如下代码

```rust
use criterion::{black_box, Criterion};

fn fibonacci(n: u64) -> u64 {
    match n {
        0 => 1,
        1 => 1,
        n => fibonacci(n-1) + fibonacci(n-2),
    }
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| b.iter(|| fibonacci(black_box(20))));
}
fn benches() {
    let mut criterion = Criterion::default().configure_from_args();
    criterion_benchmark(&mut criterion);
}

/// require run with --bench arg
fn main() {
    benches();
    Criterion::default()
        .configure_from_args()
        .final_summary();
}
```

`fn benches` 里面去掉 `configure_from_args` 就不需要强制喂一个 --bench 入参

```rust
fn benches() {
    let mut criterion = Criterion::default();
    criterion_benchmark(&mut criterion);
    criterion.final_summary();
}
fn main() {
    benches();
}
```

运行完后会生成如下目录树的报告

```
target/
└── criterion
    ├── bench_fib
    │   ├── base
    │   │   ├── benchmark.json
    │   │   ├── estimates.json
    │   │   ├── raw.csv
    │   │   ├── sample.json
    │   │   └── tukey.json
    │   ├── new
    │   │   ├── benchmark.json
    │   │   ├── estimates.json
    │   │   ├── raw.csv
    │   │   ├── sample.json
    │   │   └── tukey.json
    │   └── report
    │       ├── MAD.svg
    │       ├── SD.svg
    │       ├── index.html
    │       ├── mean.svg
    │       ├── median.svg
    │       ├── pdf.svg
    │       ├── pdf_small.svg
    │       ├── regression.svg
    │       ├── regression_small.svg
    │       ├── slope.svg
    │       └── typical.svg
    └── report
        └── index.html
```

## 怎么看 criterion 报告

首先stdout输出的 time 行有三个数据，分别是95%置信区间下界、p50中位数，上界

95%置信区间就是从中位数开始左右各95%/2组成的区间

然后 html 报告中 blue curve shows the measurements from this run 说明蓝色直方图是当前运行红色是上次运行

TODO: 如何比较一次bench中比较两个库的性能画在同一个直方图中
