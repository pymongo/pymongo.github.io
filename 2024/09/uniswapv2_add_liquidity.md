# [UniswapV2部署加流动性](/2024/09/uniswapv2_add_liquidity.md)

UniswapV1 用的 Vyper 编程语言。V2 开发的年代较早用的 waffle 进行编译构建，可能是 19 年那会还没有 Truffle,hardhat,Foundry 开发框架

首先写段代码测试下 chainlist 上随便找到 rpc 能不能用，顺便查询下某测试网的 chainId

## 部署流程简述
1. 部署Factory合约，构造函数传入feeToSetter
2. 部署Router合约，构造函数传入Factory合约地址和WETH地址
3. Factory合约上调用createPair创建交易对并添加流动性

## 协议费用feeToSetter

feeToSetter相当于协议方的地址或者说"管理员"地址

feeTo地址是协议费用收款地址，默认情况下，feeToSetter/feeTo相同，只有feeToSetter有权限修改feeToSetter/feeTo这两个地址

在 contracts/UniswapV2Pair.sol 中可看到 feeTo 如果是零地址表示没有协议费用

```solidity
    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }
```

`denominator = rootK.mul(5).add(rootKLast);` 可以看出协议费用的分母是 5k+lastK 约等于 1/6 跟注释一样

pair 合约的 _mintFee 会在每次 mint/burn 的时候调用 也就是每当添加/撤回LP的时候才**结算一次协议费**

默认交易手续费是0.3% 所以其中协议费用就是0.05%

## 交易手续费

例如用 SwapTokensForExactTokens/SwapExactETHForTokens 去要卖确定数量的 ETH

> 我踩坑过很多次 一是要把交易路径的ERC20进行approve给router 二是卖ETH的tx要转账给合约同等数量ETH让合约帮你转换成WETH

Router 合约在在外围设施的repo中 contracts/libraries/UniswapV2Library.sol

swapExactTokensForTokens->getAmountsOut->getAmountOut

```
    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
```

可以看到一边乘 997 一边除 1000 不就写死了 千3 手续费

当然 pair 合约的 swap 函数也会进行二次确认检查

> uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));

pair/router 合约写死的手续费一定是一样的

## go部署脚本

```go
package main

import (
	"context"
	"crypto/ecdsa"
	"encoding/json"
	"log"
	"math/big"
	"os"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	log.SetFlags(log.Lmicroseconds | log.Lshortfile)
	privateKeyWithout0x, err := os.ReadFile("private_key")
	if err != nil {
		log.Fatal(err)
	}
	privateKey, err := crypto.HexToECDSA(string(privateKeyWithout0x))
	if err != nil {
		log.Fatal(err)
	}
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("error casting public key to ECDSA")
	}
	addr := crypto.PubkeyToAddress(*publicKeyECDSA)
	log.Println("addr =", addr)

	client, err := ethclient.Dial("https://bsc-testnet.bnbchain.org")
	if err != nil {
		log.Fatal(err)
	}
	chainID, err := client.ChainID(context.Background()) // bsc testnet is 97
	if err != nil {
		log.Fatal(err)
	}

	jsonPath := "../v2-periphery/build/UniswapV2Router02.json"
	// jsonPath := "build/UniswapV2Factory.json"
	var contractJson struct {
		Abi      json.RawMessage
		Bytecode string
	}
	jsonStr, err := os.ReadFile(jsonPath)
	if err != nil {
		log.Fatal(err)
	}
	err = json.Unmarshal([]byte(jsonStr), &contractJson)
	if err != nil {
		log.Fatal(err)
	}
	contractABI, err := abi.JSON(strings.NewReader(string(contractJson.Abi)))
	if err != nil {
		log.Fatal(err)
	}
	var constructorArg []byte
	if strings.Contains(jsonPath, "UniswapV2Factory") {
		feeToSetterAddress := common.Address{}
		constructorArg, err = contractABI.Pack("", feeToSetterAddress)
		if err != nil {
			log.Fatal(err)
		}
	} else {
		factory := common.HexToAddress("0x7F86EDF7cff5F111Bbb51B749DfA5B05990256CE")
		weth := common.HexToAddress("0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd")
		constructorArg, err = contractABI.Pack("", factory, weth)
		if err != nil {
			log.Fatal(err)
		}
	}

	data := append(common.FromHex(contractJson.Bytecode), constructorArg...)
	nonce, err := client.PendingNonceAt(context.Background(), addr)
	if err != nil {
		log.Fatal(err)
	}
	gasPrice, err := client.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	balance, err := client.BalanceAt(context.Background(), addr, nil)
	if err != nil {
		log.Fatal(err)
	}
	bal, _ := balance.Float64()
	log.Println("eth =", bal/1e18)
	tx := types.NewContractCreation(nonce, big.NewInt(0), 7000000, gasPrice, data)

	signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)
	if err != nil {
		log.Fatal(err)
	}
	err = client.SendTransaction(context.Background(), signedTx)
	if err != nil {
		log.Fatal(err)
	}
	contractAddr, err := bind.WaitDeployed(context.Background(), client, signedTx)
	if err != nil {
		log.Fatal(err)
	}
	log.Println(jsonPath, contractAddr)
}
```

## 部署记录

- factory: [0x7F86EDF7cff5F111Bbb51B749DfA5B05990256CE](https://testnet.bscscan.com/address/0x7F86EDF7cff5F111Bbb51B749DfA5B05990256CE#code) 消耗 0.03 ETH
- router: [0x804206F9Dd3Bb7548441c45D4aa1534A0bFd2874](https://testnet.bscscan.com/address/0x804206F9Dd3Bb7548441c45D4aa1534A0bFd2874#code) 消耗 0.02 ETH

## etherscan verify

```
npm install -g @poanet/solidity-flattener
w@w:~/v2-periphery$ ./node_modules/.bin/poa-solidity-flattener ./contracts/UniswapV2Router02.sol 
{"name":"solidity-flattener","hostname":"w","pid":1205560,"level":40,"msg":"!!! @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol SOURCE FILE WAS NOT FOUND. I'M TRYING TO FIND IT RECURSIVELY !!!","time":"2024-09-11T07:00:23.665Z","v":0}
```

@uniswap 源码其实是在 node_modules/ 下面 但 solidity-flattener 工具找不到

还是用专业的 foundry 或者 hardhat 工具一键部署+验证

### foundry合约验证

[参考这篇文章用forge编译uniswap](https://blocksecteam.medium.com/use-phalcon-fork-to-learn-uniswap-v2-6b846d965f7f)

> 由于是非规范的forge项目不能用 forge remappings > remappings.txt

foundry构建估计是编译器优化参数不一样所以生成的字节码不一样(更省gas)，没被etherscan similar contract匹配到"自动开源" 

- factory: <https://testnet.bscscan.com/address/0x938993A3000ea1b50c0e986B68EF618863756181>
- router: <https://testnet.bscscan.com/address/0x00fc7f85ed70704da16fff63857ddcc224fc4a7c>
- wbnb: <https://testnet.bscscan.com/address/0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd>
- usdc: <https://testnet.bscscan.com/address/0x3fC0B4bF6AdbA22B3fe379820F0A6e87B64DE194>
- pair: <https://testnet.bscscan.com/address/0xfDE5f3bc7e0d4E94E9857092943125914c11fcE8>

```bash
set -eu
source .env
forge create --rpc-url $rpc_url \
--private-key $private_key \
contracts/v2-core/contracts/UniswapV2Factory.sol:UniswapV2Factory \
--constructor-args 0x0000000000000000000000000000000000000000 \
--verify --verifier-url "https://api-testnet.bscscan.com/api" --etherscan-api-key $etherscan_key
```

## AddPair

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract CreatePairScript is Script {
    function run() external {
        address weth = vm.envAddress("weth");
        address usdc = vm.envAddress("usdc");

        vm.startBroadcast();
        IUniswapV2Factory factory = IUniswapV2Factory(vm.envAddress("factory"));
        address pair = factory.createPair(weth, usdc);
        vm.stopBroadcast();

        console.log("Created pair at address:", pair);
    }
}
```

foundry"魔改版"uniswapv2 添加流动性会报错... 算了换回原版

- factory: https://testnet.bscscan.com/address/0x7F86EDF7cff5F111Bbb51B749DfA5B05990256CE
- router: https://testnet.bscscan.com/address/0x804206F9Dd3Bb7548441c45D4aa1534A0bFd2874

## 添加流动性

添加流动性的时候，如果交易对不存在会自动创建

```solidity
address routerAddr = vm.envAddress("router");        
address weth = vm.envAddress("weth");
address usdc = vm.envAddress("usdc");
console.log(routerAddr);
// 1BNB=520USDC
uint ethAmount = 5 * 10**17;
uint usdcAmount = 2600 * 10**6;

vm.startBroadcast(); // Start broadcasting transactions

// startBroadcast 前面调用approve 会报approve的错误 revert: TransferHelper::transferFrom: transferFrom failed
IERC20 iweth = IERC20(weth);
IERC20 iusdc = IERC20(usdc);
iweth.approve(routerAddr, type(uint256).max);
iusdc.approve(routerAddr, type(uint256).max);
// if (iweth.allowance(msg.sender, routerAddr) == 0) {
//     iweth.approve(routerAddr, type(uint256).max);
// }
require(iweth.balanceOf(msg.sender) > ethAmount, "not enough eth");
require(iusdc.balanceOf(msg.sender) > usdcAmount, "not enough usdc");

IUniswapV2Router02 router = IUniswapV2Router02(routerAddr);
(uint amountA, uint amountB, uint liquidity) = router.addLiquidity(
	weth,
	usdc,
	ethAmount,
	usdcAmount,
	1, // amountAMin
	1, // amountBMin
	msg.sender, // recipient
	block.timestamp + 35 // deadline
);
vm.stopBroadcast(); // Stop broadcasting transactions
```
