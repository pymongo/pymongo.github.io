# [128g 内存够办公么](/2023/10/use_128g_memory_for_work.md)

## 多大的数据量要 128g

我之前做图数据库开发的时候，经常导入几十 g 的 csv/jsonl 数据然后进行 k 度邻居之类的查询测试，因此 32g 内存会 OOM 我就加内存条换成 64g

朋友说他觉得 64g 都不够用，binance 全币种合约数据 1h 读到内存中就 60 多 g

## 公司电脑配置

因保密要求只能用公司台式机 win10 装上监控软件(例如禁止用微信之类的)

老板不懂电脑硬件被装机店宰客，处理器 i5 低端，显卡是亮机卡，内存太小(采购内存条已解决)

固态用的 sata(device_manager.disk.hardware_id 中看不到 nvme) 

比我自己之前配的台式机编译速度慢 2 成, 5900X 编译 ra 需要 70s 而 i5-12600k 需要 85s

看了下主板技嘉 B660M 支持最新的 i9-13900k, 公司电脑卸掉亮机卡 450W-550W 电源应该能带动，功率再不够就禁用大核的超线程(但不上水冷没法完全发挥性能)

## 公司网速测试

开发流程是改代码增量编译通常花费 5-7s 再 scp 到云主机上执行验证代码的正确性，但裸连 scp 到东京云主机往往网速就 600k/s 左右需要 11-15s

所以连 USB 无线网卡的网速都没打满换网线也没用，阻碍开发效率的大头在 scp 速度

### apt install speedtest-cli

```
Retrieving speedtest.net server list...
Selecting best server based on ping...
Hosted by China Telecom JiangSu 5G (Suzhou) [83.01 km]: 22.442 ms
Download: 30.21 Mbit/s
Upload: 33.15 Mbit/s
```

基本跟连上 v2ray 东京节点后 speedtest 网站测试上行下载速度 30M 一致，意味着开代理不会损失太多性能

云主机上面测试结果是 200M/300M 网速

### 云主机 scp 速度

||scp 8.7M 耗时|
|---|---|
|无代理|12s|
|ProxyCommand corkscrew|4.485s|
|代理且 scp -C|3.1s|
|mscp|8.1s|

update: wsl2 用 /etc/resolve.conf 里面的 ip 亦可

我现在的 ssh 代理配置是 `ProxyCommand=nc -x 172.25.240.1:10808 %h %p` 只设置到云主机下面没有设置成全局，设置成全局的话就公司git私服就连不上了

## pre-commit hook

新公司领导说我们代码还有 clippy 报错就提交了习惯不太好。github 公共的免费 CI 还是自建的 CI 又太慢了，显得 pre commit hook 非常有用，如果没有 fmt 的代码就拒绝 commit

> pip3 install pre-commit

每个项目初始化一次, 会创建一个 .git/hooks/pre-commit 的 bash/python 脚本在 commit 前执行 .pre-commit-config.yaml

```yaml
fail_fast: false
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v3.3.0
    hooks:
      - id: end-of-file-fixer
      - id: trailing-whitespace
  - repo: local
    hooks:
      - id: cargo-fmt
        name: cargo fmt
        description: Format files with rustfmt.
        entry: bash -c 'cargo fmt -- --check'
        language: rust
        files: \.rs$
        args: []
      - id: cargo-test
        name: cargo test
        description: run stateless unittest
        entry: cargo test --all -- --nocapture
        language: rust
        files: \.rs$
        pass_filenames: false
```

如果没改动 rs 文件 就不会触发 commit hook, 如果有 commit 的时候还有几个脏文件，第一个检查会拒绝提交(治好了我的坏习惯)

```
Fix End of Files.........................................................Passed
Trim Trailing Whitespace.................................................Passed
cargo fmt............................................(no files to check)Skipped
cargo check..........................................(no files to check)Skipped
```

