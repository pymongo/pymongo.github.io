# [abigen](/2024/07/abigen.md)

我之前 UniswapV2 手写 Uniswap ABI 绑定数据的 Go 结构体，手写了几百行之后，一是怕写错，二是重复劳动太累，网上一搜找到个 abigen 的工具可以输入 .sol 源码或者 abi json 文件 codegen 出相应的 Go 代码

例如 [Mantle binding 库](https://github.com/mantlenetworkio/mantle/blob/main/mt-batcher/Makefile)

还有 OP v1.7.0 版本的 op-bindings/bindgen/utils.go (新版本因monorepo缘故挪到别的地方了)

> cmd := exec.Command("abigen", "--abi", abiFilePath, "--bin", bytecodeFilePath, "--pkg", goPackageName, "--type", contractName, "--out", outFilePath)

go install github.com/ethereum/go-ethereum/cmd/abigen@latest

abigen 必须要传入 --pkg 参数，不加 --type 参数指定结构体前缀的话，所有结构体都是 Bindings 开头容易重名

> abigen --abi exchange/bindings/uniswapv2_pair.abi --out exchange/bindings/uniswapv2_pair.go --type UniswapV2Pair --pkg bindings
> 
> abigen --abi exchange/bindings/erc20.abi --out exchange/bindings/erc20.go --type Erc20 --pkg bindings

## 查询 getReserve

```go
uniswapClient, err := bindings.NewUniswapV2Pair(pairAddresses[0], client)
if err != nil {
    log.Fatalln(err)
}
res, err := uniswapClient.GetReserves(nil)
if err != nil {
    log.Fatalln(err)
}
log.Printf("uniswapClient GetReserves %#v", res)
```

## ws 订阅事件

```go
swapLogs := make(chan *bindings.UniswapV2PairSwap)
swapSub, err := uniswapClient.WatchSwap(nil, swapLogs, nil, nil)
if err != nil {
    log.Fatalf("Failed to subscribe to Swap events: %v", err)
}
syncLogs := make(chan *bindings.UniswapV2PairSync)
syncSub, err := uniswapClient.WatchSync(nil, syncLogs)
if err != nil {
    log.Fatalf("Failed to subscribe to Sync events: %v", err)
}
for {
    select {
    case swap := <-swapLogs:
        log.Printf("swapLogs %#v\n", swap)
    case sync := <-syncLogs:
        log.Printf("syncLogs %#v\n", sync)
    case err := <-swapSub.Err():
        log.Fatalln(err)
    case err := <-syncSub.Err():
        log.Fatalln(err)
    }
}
```

## abigen 不支持批量查询

abigen 生成的 getReserve 返回值数据结构体还是个匿名结构体不能给其他函数使用...

如果需要批量rpc查询，还是得自己定义输入输出数据的结构体去序列化

## Rust sol! 宏

由于 ether-rs 已经 deprecated 了 foundry 用的是 alloy

> alloy = { version="0.2", features=["contract"] }

```rust
alloy::sol!(
    #[sol(rpc)]
    IUniswapV2Pair,
    "uniswapv2_pair.abi"
);
#[tokio::main]
async fn main() {
    let rpc_url = "https://rpcapi.fantom.network";
    let provider = alloy::providers::ProviderBuilder::new().on_http(rpc_url.parse().unwrap());
    const ADDR: alloy::primitives::Address =
        alloy::primitives::address!("084F933B6401a72291246B5B5eD46218a68773e6");
    let pair = IUniswapV2Pair::new(ADDR, provider);
    let r = pair.getReserves().await.unwrap();
    dbg!(r._reserve0, r._reserve1);
}
```

然后遇到了 does not live long 报错...

```
error[E0597]: `pair` does not live long enough
  --> src/main.rs:15:13
   |
14 |     let pair = IUniswapV2Pair::new(ADDR, provider);
   |         ---- binding `pair` declared here
15 |     let r = pair.getReserves().await.unwrap();
   |             ^^^^--------------
   |             |
   |             borrowed value does not live long enough
   |             argument requires that `pair` is borrowed for `'static`
16 |     dbg!(r._reserve0, r._reserve1);
17 | }
   | - `pair` dropped here while still borrowed
```

再参考下 alloy book 例子 https://alloy.rs/examples/contracts/interact_with_abi.html?highlight=codegen#example

把 `pair.getReserves()` 加个 .call() 去克隆获得所有权就没生命周期报错 `pair.getReserves().call()`

运行时 遇到 `Connect, "invalid URL, scheme is not http"`

解决办法 alloy crate 加 feature **"provider-http"**

sol! 宏内不加 `#[sol(rpc)]` 的话就不会生成 rpc 调用相关代码
