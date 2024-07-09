# [Rust调用sui合约](/2024/07/rust_call_sui_contract_function.md)

照着move-book教程 <https://move-book.com/your-first-move/hello-sui.html> 很快写完 move 合约部署到测试网

创建一个 todo_list Object 并将 ownership 转移给我自己的合约调用如下(ptb=ProgrammableTransactionBuilder)

```bash
sui client ptb \
  --assign sender @$(sui client active-address) \
  --move-call $PACKAGE_ID::todo_list::new \
  # 将new函数的返回值保存到list中
  --assign list \
  # transfer 之后用 sui client objects --json 就能看到我拥有个 TodoList Object
  --transfer-objects "[list]" sender
```

sui client ptb 一次可以传入多个 --move-call 但字符串的入参要单双引号两个参数转义 否则就报错如下

```
sui client ptb --move-call 0x702815e66354365ec77e0ea708912725be4e8e0407b041e11f3b3f733c2a4a53::todo_list::add @0x6d08e394bcc4dec6a8349f1ffb4e5630c0cd55df1ba9882cfe66dfa5b1f7d130 'item 3'
   ╭────
 1 │ --move-call 0x702815e66354365ec77e0ea708912725be4e8e0407b041e11f3b3f733c2a4a53::todo_list::add @0x6d08e394bcc4dec6a8349f1ffb4e5630c0cd55df1ba9882cfe66dfa5b1f7d130 item 3 
   ·                                                                                                ─────────────────────────────────────┬────────────────────────────────────
   ·                                                                                                                                     ╰── Expected 2 arguments, but got 3
```

sui client ptb 或者 call 都能调用合约，但 ptb 的功能更多点不仅限于调用合约

> sui client ptb --move-call 0x702815e66354365ec77e0ea708912725be4e8e0407b041e11f3b3f733c2a4a53::todo_list::add @0x6d08e394bcc4dec6a8349f1ffb4e5630c0cd55df1ba9882cfe66dfa5b1f7d130 ''\''item 2'\'''

> sui client call --package 0x702815e66354365ec77e0ea708912725be4e8e0407b041e11f3b3f733c2a4a53 --module todo_list --function add --args 0x6d08e394bcc4dec6a8349f1ffb4e5630c0cd55df1ba9882cfe66dfa5b1f7d130 'item 2'

最后区块浏览器查看 <https://suiscan.xyz/testnet/object/0x6d08e394bcc4dec6a8349f1ffb4e5630c0cd55df1ba9882cfe66dfa5b1f7d130>

sui/sol/apt一样，数据存储需要支付押金 Storage Rebate <https://docs.sui.io/concepts/tokenomics/gas-pricing?ref=blog.sui.io#storage>

可以类似sol销户那样退存储押金

## 背景知识

### struct SuiObjectData

<https://docs.sui.io/concepts/object-model>

核心字段(组成 ObjectRef ):
- object_id: u256
- version: SequenceNumber
- digest: hash of the object's contents and metadata

发送交易的是必须要传入 GasCoin 的 ObjectRef, 如果要修改 Object 函数入参第一个一般都是 ObjectRef

悲剧的是**区块浏览器**不能获取到 digest (我一开始还以为是nonce作用类似的previous_transaction digest)

例如我 todo_list object 修改了三次之后 digest 是 o#B1t1pVwpn8vQ9LDEeKT5HY6wA859rPHwuJwUGW1NcXyt

理论上修改第四次的时候 digest 会变，果然变了 o#n9pBGbgV3fF2R2KDDWicVitys7PGvStQgYSizo4R5N9

### tx commands
- SplitCoins: 例如支付GAS
- MoveCall: 调用智能合约函数
- TransferObjects

Transaction effects are the changes that a transaction makes to the blockchain state

### sign tx

<https://docs.sui.io/guides/developer/sui-101/sign-and-send-txn>

tx_data 通过 `bcs::to_bytes` 序列化成 Vec<u8> 后面再用 blake2 哈希出摘要，摘要+签名算法flag+公钥 一起签名得到 Signature

整个过程跟 bluefin 交易所下单/撤单的交易签名类似

### ptb

<https://docs.sui.io/guides/developer/sui-101/building-ptb>

### SuiClientCommands::Call

照着 sui 源码 Call sub command 的处理流程读一遍，就加深对 sui 调用合约函数过程的理解

## Rust 代码实现

参考 crates/sui-sdk/examples/function_move_call.rs

Cargo.toml

```
sui_sdk = { git = "https://github.com/mystenlabs/sui", package = "sui-sdk"}
sui_keys = { git = "https://github.com/mystenlabs/sui", package = "sui-keys"}
shared_crypto = { git = "https://github.com/mystenlabs/sui", package = "shared-crypto"}
bcs = "0.1.6"
```

初始化查询下 sui 的 ObjectRef 信息和我自己 Object 信息，后续可以优化成只查询一次缓存下来

```rust
let sui_client = sui_sdk::SuiClientBuilder::default().build_testnet().await.unwrap();
let sender: SuiAddress = my_addr.parse().unwrap();
let coins = sui_client.coin_read_api().get_coins(sender, None, None, None).await.unwrap();
let gas_coin = coins.data.into_iter().next().unwrap();

let object_id: ObjectID = object_id.parse().unwrap();
let obj = sui_client.read_api().get_object_with_options(object_id, SuiObjectDataOptions::bcs_lossless()).await.unwrap().data.unwrap();
dbg!(&obj.digest);
```

请求的入参封装如下

```rust
let mut ptb = ProgrammableTransactionBuilder::new();
let arg0 = CallArg::Object(ObjectArg::ImmOrOwnedObject((obj.object_id, obj.version, obj.digest)));
// Add this input to the builder
ptb.input(arg0).unwrap();
let arg1 = "item 4";
ptb.input(CallArg::Pure(bcs::to_bytes(&arg1).unwrap())).unwrap();
let pkg_id = "0x702815e66354365ec77e0ea708912725be4e8e0407b041e11f3b3f733c2a4a53";
let package = ObjectID::from_hex_literal(pkg_id).unwrap();
let module = Identifier::new("todo_list").unwrap();
let function = Identifier::new("add").unwrap();
ptb.command(Command::MoveCall(Box::new(ProgrammableMoveCall {
    package,
    module,
    function,
    type_arguments: vec![],
    arguments: vec![Argument::Input(0), Argument::Input(1)],
})));
let builder = ptb.finish();
```

这个函数对应的 move 源码 以及 ABI

```move
module todo_list::todo_list {
// 因为sui有次升级为了方便前端tx调用合约函数，没有entry修饰的函数也可以rpc调用了
public fun add(list: &mut TodoList, item: String) {
    list.items.push_back(item);
}
}
```
