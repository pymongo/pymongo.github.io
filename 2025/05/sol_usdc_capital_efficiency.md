# [SOL cap efficiency](/2025/05/sol_usdc_capital_efficiency.md)

Lifinity用24hVol/TVL作为指标量化LP的资金利用率Capital Efficiency, 我之前以为SOL/USDC中利用率最高是meteora DLMM 1bp池子

```
dex,24h Vol,TVL,24hVol/TVL,pool addr
Solfi,143956627,1372503,105,5guD4Uz462GT4Y4gEuqyGsHZ59JGxFN4a3rF6KWguMcJ
Solfi,162720055,2878738,57,CAPhoEse9xEH95XmdnJjYrZdNCA8xfUWdy3aWymHa1Vj
Solfi,66807463,1227945,54,3nQAMo837oPuGCGELcw2wo7C9hUUchsMWCneiPHFFdur
Lifinity,65316521,1362050,48,DrRd8gYMJu9XGxLhwTCPdHNLXCKHsxJtMpbn62YqmwQe
Meteora,27157382,727066,37,HTvjzsfX3yU6BUodCjZ5vZkUrAxMDTrBs3CJaq43ashR
RayCLMM,147789330,4618215,32,8sLbNZoA1cfnvMJLPfp98ZLAnFSYCFApfJKMbiXNLwxj
Meteora,81914788,4571844,18,5rCf1DM8LjKTw4YqhnoLcngyZYeNnQqztScTogYHAS6
Orca,326835947,35866068,9,Czfq3xZZDmsdGdUyrNLtRhGc47cXcZtLG4crryfu44zE
RayCLMM,55783830,8301672,7,3ucNos4NbumPLZNWztqGHNFFgkHeRMBQAVemeeomsUxv
```

| dex | 24h Vol | TVL | Vol/TVL | pool addr |
|-----|---------|-----|------------|-----------|
| Solfi | 1.44亿 | 137万 | 105 | 5guD4Uz462GT4Y4gEuqyGsHZ59JGxFN4a3rF6KWguMcJ |
| Solfi | 1.63亿 | 288万 | 57 | CAPhoEse9xEH95XmdnJjYrZdNCA8xfUWdy3aWymHa1Vj |
| Solfi | 6681万 | 123万 | 54 | 3nQAMo837oPuGCGELcw2wo7C9hUUchsMWCneiPHFFdur |
| Lifinity | 6532万 | 136万 | 48 | DrRd8gYMJu9XGxLhwTCPdHNLXCKHsxJtMpbn62YqmwQe |
| Meteora | 2716万 | 72.7万 | 37 | HTvjzsfX3yU6BUodCjZ5vZkUrAxMDTrBs3CJaq43ashR |
| RayCLMM | 1.48亿 | 462万 | 32 | 8sLbNZoA1cfnvMJLPfp98ZLAnFSYCFApfJKMbiXNLwxj |
| Meteora | 8191万 | 457万 | 18 | 5rCf1DM8LjKTw4YqhnoLcngyZYeNnQqztScTogYHAS6 |
| Orca | 3.27亿 | 3587万 | 9 | Czfq3xZZDmsdGdUyrNLtRhGc47cXcZtLG4crryfu44zE |
| RayCLMM | 5578万 | 830万 | 7 | 3ucNos4NbumPLZNWztqGHNFFgkHeRMBQAVemeeomsUxv |


https://x.com/ospopen/status/1921497335927865575

```
Lifinity有个指标叫Capital Efficiency用来量化池子的资金利用率
我研究了下 SOL/USDC 不同池子利用率 发现Solfi是资金利用率有100多是最高的
100万资金一天交易量过亿换手100多次
对LP来说意味着jup聚合器更大概率路由到Solfi

Lifinity是只允许项目方量化团队/算法加LP提高利用率 不知Solfi如何提高资金利用率了

数据来源solscan
```
