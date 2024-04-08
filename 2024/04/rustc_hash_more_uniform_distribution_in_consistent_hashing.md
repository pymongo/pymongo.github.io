# [fxhash一致性哈希更均匀?](/2024/04/rustc_hash_more_uniform_distribution_in_consistent_hashing.md)

用哈希桶/一致性哈希算法将 bn/gate u本位合约共有交易对 分摊到 3个或者6个节点运行

```
stdhash max-min=20, std_dev(方差)=8.6
0 88
1 72
2 92

fxhash max-min=11, std_dev(方差)=4.5
0 89
1 85
2 78
```

而节点数变成六个时, siphash的方差是5.7比fxhash的7.3更均匀更加负载均衡
