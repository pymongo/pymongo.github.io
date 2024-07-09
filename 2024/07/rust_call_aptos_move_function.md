# [Rust调用aptos合约](/2024/07/rust_call_aptos_move_function.md)

## sui/apt推文感想

想到自己还有房贷要还，朋友邀请我搞aptos副业赚点米，例如刷合约交互撸毛,组队hackathon
move我没时间学完，就想着Rust调用move合约函数刷交互(之前我Rust调sui合约赚了碗猪脚饭)
aptos Rust SDK文档就一页example都没 ts才是一等公民有几十页文档 问claude3.5连aptos是啥都不知
啃aptos源码 成功签名交易

我不太想学move/sui/aptos/rooch的原因
一是连最先进的AI claude3.5都没有move/aptos训练数据，没AI帮助学习难度大
二是朋友说move很可能步入EOS C++智能合约后路，几年前同事都在吹EOS，前几天EOS都跌到发行价的40%
项目都是有周期性的，move可能就几年生命周期

为什么魔兽世界公会DKP团会灭绝，因为新人白打工，老人积分换完装备退会，分配不公平毛人很多
怀旧服都只有金团，像我这样没时间肝游戏的只能玩支付宝团

DKP经济模型被淘汰说明让人用爱发电换流动性很差的资产不可能了，所以开发者社区基金会通常用美元(例如grants)激励开发者

<https://x.com/ospopen/status/1810526736326807964>

## Resource

Resource 类似于 sui 的 Object

例如 [aptos first move example](https://aptos.dev/en/build/guides/first-move-module) 里面

第一次调用 set_message 会给我自己创建一个 message 的 Resource

> 0xb411e3fd045765c73deca67f91be38131373dbf9eec0309068403558fe0bc202::message::MessageHolder

## gas 设置

1SUI=10.pow(9)MIST, 1APTOS=10.pow(8)octas

测试网 gas_price 默认是 100 如果设置了 0.1 的 max_gas 会报错 MAX_GAS_UNITS_EXCEEDS_MAX_GAS_UNITS_BOUND

也就是 max_gas/gas_price 不能设置太高

## 函数入参

```move
module hello_blockchain::message {
    public entry fun set_message(account: signer, message: string::String)
    acquires MessageHolder {
        let account_addr = signer::address_of(&account);
        if (!exists<MessageHolder>(account_addr)) {
            move_to(&account, MessageHolder {
                message,
            })
        } else {
            let old_message_holder = borrow_global_mut<MessageHolder>(account_addr);
            let from_message = old_message_holder.message;
            event::emit(MessageChange {
                account: account_addr,
                from_message,
                to_message: copy message,
            });
            old_message_holder.message = message;
        }
    }    
}
```

`module hello_blockchain::message` 中 hello_blockchain 是 move 文件名，**message 才是 module 名**

如果 ModuleId + FunctionId 找不到会报错 **LINKER_ERROR**

```rust
let payload = TransactionPayload::EntryFunction(EntryFunction::new(
    ModuleId::new(sender_address, "message".parse().unwrap()),
    "set_message".parse().unwrap(),
    vec![],
    vec![bcs::to_bytes("hello").unwrap()],
));
```

跟 sui 一样，type_args 指的是函数的泛型入参，我们没有所以填入空即可

我的完整代码 <https://github.com/pymongo/aptos_example>
