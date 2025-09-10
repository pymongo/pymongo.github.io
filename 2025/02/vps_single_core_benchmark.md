# [VPS单核性能测试](/2025/02/vps_single_core_benchmark.md)

> sysbench --test=cpu --cpu-max-prime=20000 run

> stress-ng --cpu 1 --cpu-method prime --timeout 10s --metrics

| cpu | sysbench | stress(bogo real) | note |
|-----|----------|----------------------|------|
| 9950X | 26545 | | compile ra 40s |
| 9700X | 25731 | 3055 |
| 7950X | 23638 | 2963 | hostkey |
| 9274F | 18599 | | |
| 13900H | 17124 | | my laptop compile ra 87s |
| 9454P | 17033 | | hetzner AX162-R |
| 9R14 | 16776 | 2013 | aws c7a |
| 7002 | 16443 | 2025 | hetzner x86 6€ |
| 9354 | 16089 | 1943 | hostkey VPS 7€ |
| Neoverse-N1 | | 12688 | hetzner arm |
| 8488C | 12446 | | aws c7i-flex |
| 7402 | 6230 | 596 | living-bot |

```
cpu,sysbench,stress(bogo real),note
9950X,26545,,compile ra 40s
9700X,25731,3055
7950X,23638,2963,hostkey
9274F,18599,,
13900H,17124,,my laptop compile ra 87s
9454P,17033,,hetzner AX162-R
9R14,16776,2013,aws c7a
amd-hp,16643,1864,vultr6$
7002,16443,2025,hetzner x86 6€
9354,16089,1943,hostkey VPS
12500,13317,2079,hetzner auction
Neoverse-N1,,12688,hetzner arm
8488C,12446,,aws c7i-flex
E5-2686,9985,439,aws t2.micro
7402,6230,596,living-bot
intel,3247,840,vultr5$
,3911,347,阿里云经济型
```

根据 www.cpubenchmark.net 数据 9274F,5900X,9950X 的单核性能分别是 3373,3470,4744
