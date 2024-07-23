# [Uniswap ws订阅行情](/2024/07/uniswap_batch_rpc_ws_subscribe_price.md)

由于 Uniswap V1 版本必须包含 ETH 所以两个 token 之间交换必须先换成 ETH 去中转，效率很低 V1 已经彻底弃用了

由于 V3 版本 CLMM 和 V4 版本的 DLMM 数学模型过于复杂，还是先从 AMM 模型的 V2 进行入门和学习

## Uniswap 三种合约

Uniswap V2 的运转涉及三种智能合约

- IUniswapV2Router 类似于网关通过输入两个 token 地址从而找到 Pair 合约地址进行交易
- IUniswapV2Factory 包含所有 Pair 信息 检索交易对、上架交易对
- IUniswapV2Pair 进行两个 token 之间交易

### 常用智能合约函数

- IUniswapV2Router: factory 获取关联的 factor 地址
- IUniswapV2Factory: allPairsLength 获取交易对(Pair)总数; allPairs(i) 获取第 i 个交易对地址
- IUniswapV2Pair: getReserves 获取交易对两种 token 数量根据 AMM 算法计算出价格

本文重点聚焦在如何跟 Pair 合约进行交互获取价格行情，对应的合约源码在 <https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol>

## 初始化 go 查询价格项目

```
go mod init uniswap
go get github.com/ethereum/go-ethereum
go get github.com/ethereum/go-ethereum/ethclient
#go get github.com/ethereum/go-ethereum/rpc
```

## embed 集成 ABI 文件

go embed 类似 Rust 的 include_str!

由于 IUniswapV2Pair.sol 的 ABI json (可在 etherscan 下载) 太长了，写死在代码中不利于代码阅读和逻辑解耦

可用 `//go:embed IUniswapV2Pair.abi.json` 的方式读取 abi 文件内容集成到可执行文件种

## 价格换算代码

我们暂时只关心 ETH 跟 USDC 之间的 Pair, getReserve 返回的两个 token 数量，除以各自的 10**decimals 如此就得到真实数量

最后根据 AMM 模型拿 USDC 数量除以 ETH 数量就得到了 ETH 的价格了

```go
type Pair struct {
	addr       common.Address
	token0Addr common.Address
	token1Addr common.Address
	decimalsMul0 *big.Int // e.g. 1e18
	decimalsMul1 *big.Int
	reserve      Reserves
	// e.g. quote_coin/token1 is USDC so price is reserve0/reserve1, Vice versa
	quoteIsStableCoin bool
}
func (pair *Pair) amount0() float64 {
	reserve := new(big.Int).Set(pair.reserve.Reserve0)
	reserve.Div(reserve, pair.decimalsMul0)
	amount := new(big.Float).SetInt(reserve)
	float, _ := amount.Float64()
	return float
}
func (pair *Pair) amount1() float64 {
	reserve := new(big.Int).Set(pair.reserve.Reserve1)
	reserve.Div(reserve, pair.decimalsMul1)
	amount := new(big.Float).SetInt(reserve)
	float, _ := amount.Float64()
	return float
}
func (pair *Pair) price() float64 {
	amount0 := pair.amount0()
	amount1 := pair.amount1()
	if pair.quoteIsStableCoin {
		return amount1 / amount0
	} else {
		return amount0 / amount1
	}
}
```

### 为什么不用 decimal 类型进行数量除法换算

由于 uint112 位数太多浮点数没法精确表示，为什么不用 例如 rust_decimal, python decimal, big.Float 进行更精确的浮点数相除呢?

原因是性能和准确性二者不可兼得，牺牲一点点误差 trade-off 取舍换得更好性能

我们看以下测试数据 price 用 big.Int 换算 decimals, priceF 用 big.Float 换算 decimals 二者几乎没有误差

```
price= 3.820039 amount0= 83231.000000 amount1= 21788.000000
priceF=3.820073 amountF0=83231.921203 amountF1=21788.047366

price= 0.520731 amount0= 1271582.000000 amount1= 2441917.000000
priceF=0.520731 amountF0=1271582.547983 amountF1=2441917.863439

price= 0.520929 amount0= 2461380.000000 amount1= 1282203.000000
priceF=0.520928 amountF0=2461380.624467 amountF1=1282203.123785

price= 0.520714 amount0= 2637122.000000 amount1= 1373186.000000
priceF=0.520714 amountF0=2637122.261482 amountF1=1373186.008633
```

整数除法算出的价格和用 big.Float 换算出的价格，误差小于 1e-8 基本可以忽略

## rpc 请求价格

```go
func queryReserves(contract *abi.ABI, client *ethclient.Client, pairAddress common.Address) {
	callData, err := contract.Pack("getReserves")
	if err != nil {
		log.Fatalf("Failed to pack call data: %v", err)
	}
	msg := ethereum.CallMsg{
		To:   &pairAddress,
		Data: callData,
	}
	res, err := client.CallContract(context.Background(), msg, nil)
	if err != nil {
		log.Fatalf("Failed to call contract: %v", err)
	}
	outputs, err := contract.Unpack("getReserves", res)
	if err != nil {
		log.Fatalf("Failed to unpack call result: %v", err)
	}
	var reserve Reserves
	method.Outputs.Copy(&reserve, values)
	pair := pairs[pairAddress]
	// pair.reserve = Reserves{
	// 	Reserve0:           outputs[0].(*big.Int),
	// 	Reserve1:           outputs[1].(*big.Int),
	// 	BlockTimestampLast: outputs[2].(uint32),
	// }
    price := pair.price()
}
```

假如有 100 个交易对，就要调用 100 次 queryReserves 请求，公共免费的 rpc 节点通常限制 1s 请求 5 次 怎样批量请求呢？

方案一是调用自己部署的 multicall 智能合约里面批量请求，方案二是使用 rpc.BatchElem 批量请求

## 批量 rpc 请求价格

```go
func queryReserves(pairAbi *abi.ABI, client *rpc.Client) {
	method, exists := pairAbi.Methods["getReserves"]
	if !exists {
		log.Fatal("pairAbi.Methods")
	}
	methodIdSignature := hexutil.Encode(hexutil.Bytes(method.ID))
	log.Println("method.Sig", method.Sig, "methodIdSignature", methodIdSignature, "method.ID")
	batch := make([]rpc.BatchElem, len(pairAddresses))
	for i, addr := range pairAddresses {
		_ = addr
		batch[i] = rpc.BatchElem{
			Method: "eth_call",
			Args: []interface{}{
				map[string]string{
					"to": addr.Hex(),
					"data": methodIdSignature,
				},
				"latest",
			},
			// You are using []byte for the Result, but it’s often safer to use a hexutil.Bytes type or directly handle it as string to avoid encoding issues
			Result: new(hexutil.Bytes),
			// Result: &Reserves{},
		}
	}
	err := client.BatchCall(batch)
	if err != nil {
		log.Fatalf("Batch call failed: %v", err)
	}
	for i, elem := range batch {
		pairAddress := pairAddresses[i]
		if elem.Error != nil {
			log.Fatalf("Error fetching reserves for pair %s: %v", pairAddress, elem.Error, )
			continue
		}
		reserveData := (*elem.Result.(*hexutil.Bytes))
		outputs, err := method.Outputs.UnpackValues(reserveData)
		if err != nil {
			log.Fatalln(err)
		}
		reserve0 := outputs[0].(*big.Int)
		reserve1 := outputs[1].(*big.Int)
		blockTimestampLast := outputs[2].(uint32)
		// ...
	}
}
```

注意踩坑的点是 `rpc.BatchElem.result` 不能定义成 []byte 去反序列化，AI 可能会骗你用 []byte ，会报错的

eth json rpc 返回的格式是 "result":"0x0000000" 也就是 go-ethereum/rlp 编码格式所有数据按字段格式编码成十六进制拼接起来

eth 的 hexutil.Bytes类型也是个 []byte 的 newtype 设计模式，但是兼容的

在 sui 的交易数据签名中也有类似 ETH 的 RLP 编码格式

在 eth 的 types.Block 类型中，自行实现了特殊的 json/rlp marshal 处理，所以可以直接直接作为"类型参数"放在 result 中反序列化

## ws 订阅 Uniswap 行情

由于免费的 rpc 节点大多不提供 ws 服务，这部分内容就简要概述下

Pair 有六个 Event 其中 Approval 不会发生数量变化就不订阅

eventSignature 的概念就类似于 Topic

```go
func subscribeEvents(contract abi.ABI, wsClient *rpc.Client, pairAddresses []common.Address) {
	ethClient := ethclient.NewClient(wsClient)
	abiCtx := AbiCtx {
		Swap: newEvtCtx(&contract, "Swap"),
		Sync: newEvtCtx(&contract, "Sync"),
		Burn: newEvtCtx(&contract, "Burn"),
		Mint: newEvtCtx(&contract, "Mint"),
		Transfer: newEvtCtx(&contract, "Transfer"),
	}
	query := ethereum.FilterQuery{
		Addresses: pairAddresses,
		// Topic就是EventSignature的意思用于标识事件的唯一标识符。每个事件都有一个固定的签名
		Topics: [][]common.Hash{{
			abiCtx.Swap.id,
			abiCtx.Sync.id,
			abiCtx.Burn.id,
			abiCtx.Mint.id,
			abiCtx.Transfer.id,
			// Approval 不会发生 token 数量变化
		}},
	}
	logs := make(chan types.Log)
	sub, err := ethClient.SubscribeFilterLogs(context.Background(), query, logs)
	if err != nil {
		log.Fatalf("Failed to subscribe to logs: %v", err)
	}
	for {
		select {
		case err := <-sub.Err():
			log.Fatalf("Subscription error: %v", err)
		case vLog := <-logs:
			handleLog(&abiCtx, vLog)
		}
	}
}
```

以下是 ws log event handler 部分代码

```go
func handleLog(abiCtx *AbiCtx, logEvt types.Log) {
	pairAddress := logEvt.Address
	pair := pairs[pairAddress]
	switch logEvt.Topics[0] {
	case abiCtx.sync.id: // EventSignature
		values, err := abiCtx.sync.arg.UnpackValues(logEvt.Data)
		if err != nil {
			log.Fatalf("Failed to unpack Sync event: %v", err)
		}
		var reserve Reserves
		err = abiCtx.sync.arg.Copy(&reserve, values)
		if err != nil {
			log.Fatalln(err)
		}
		pair.reserve = reserve
		log.Printf("ws_event Sync %s price %f\n", pair.name, pair.price())
	}
}
```

## ws 为什么会收到多个 Topic

> Received log: {Address:0x2D0Ed226891E256d94F1071E2F94FBcDC9060E14 Topics:[0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822 0x0000000000000000000000005023882f4d1ec10544fcb2066abe9c1645e95aa0 0x0000000000000000000000002c846bcb8aa71a7f90cc5c7731c7a7716a51616e] Data:[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 21 173 145 185 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 37 242 115 147 61 181 112 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] BlockNumber:86354646 TxHash:0x534d7d16b35bf078fb681a54794ed51fafdb88993df76e9c93b9e1b242513540 TxIndex:1 BlockHash:0x0004801c00001dcfd0982594eccebf02fec83d1bd34a5a5f3326f9f7540e3983 Index:3 Removed:false}

其实 Topics[0] 才是事件名字 后面都是事件的参数
