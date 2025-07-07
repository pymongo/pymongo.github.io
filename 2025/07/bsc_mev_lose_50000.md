# [bsc被夹5万](/2025/07/bsc_mev_lose_50000.md)

当时怕br暴跌滑点平不掉 滑点设置无限大，结果被黑客夹我swap代码巨亏

```
if (token0 == usdt || token0 == usdc || token0 == usd1) {
    zeroForOne = false;
    sqrtPriceLimitX96 = TickMath.MAX_SQRT_RATIO-1;
    inAmount = amount1Collected;
} else {
    zeroForOne = true;
    sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO+1;
    inAmount = amount0Collected;
}
lastSender=address(this); // need contract send to pool, because closeLp collect fund to this contract
IUniswapV3PoolActions(pool).swap(
    msg.sender, // recipient
    zeroForOne,
    int256(inAmount),
    sqrtPriceLimitX96,
    abi.encode(zeroForOne, token0, token1) // callback data
);
```

这笔tx用的 dataseed.binance 发的 没有用隐私节点 当然我觉得就算用48club也不排除被夹

https://web3.okx.com/explorer/bsc/tx/0xe76c65e27106613b28faf8fcef98ca690453b5161034c38dd25981e2545ecfd0

钉钉上看到仓位跌破区间从，只能说自己代码写的烂 以后最多放2-3万u了，不然黑客盯上就归零了

连高手如云的48club交易竞赛代码都写出bug一个人撸走86000 https://x.com/48Club_Official/status/1942077944597520699

难受 打破我最亏的记录 之前最大记录是 solana的libra被撤池子割7000 和缅北电信诈骗骗掉我12000

这次被骗 没有第一次被电信诈骗 8万6人民币难受好几个月，还是诈骗份子让我网贷  负债2万

有人曾经跟我说包在合约里面swap防夹，现在看也没用，夹子会模拟每笔交易所有event和调用
