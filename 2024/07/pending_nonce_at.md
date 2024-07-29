# [PendingNonceAt](/2024/07/pending_nonce_at.md)

> 在 eth 中 pending 和 latest 概念有什么区别? 我看 go eth 的 PendingNonceAt 和 NonceAt 都是调用的 eth_getTransactionCount 方法，但 PendingNonceAt 传入的是 pending。在 web3.py 或者 web3.js 中，也是有这两种api的区分吗？如果我做的是一个钱包软件，为了减少http请求，初始化的时候应该用那种？后续增量更新 nonce 应该是 交易成功就 nonce += 1 这样吧，就避免了频繁轮询nonce

pending 要比 latest "更新" 代表的是包括正在内存池中等待被矿工打包的交易

下一个将要被打包进区块的交易的预期nonce值，如果没有 pending 交易的话这两应该是相等的

因为 golang 的 eth abi 设计上传入一个 big.Int 作为 NonceAt 的参数，如果想要查询内存池中 pending 交易的话

只能再提供一个 PendingNonceAt 去查询

python,js 的 web3 库中 既可以传入数字也能传入字符串latest默认是 latest

> web3.eth.getTransactionCount(addr, "pending")
