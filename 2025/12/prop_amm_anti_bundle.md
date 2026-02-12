# [暗池如何识别bundle](/2025/12/prop_amm_anti_bundle.md)

暗池做市商不喜欢 原子套利 这样有毒订单流侵蚀他们的利润

既然用 sysvar 识别有没有同一笔 tx 既买又卖，套利者就用bundle把买卖两个指令拆分到两个tx

暗池之前喜欢带 jitodontfront 这样 jitodontfront1111111111111111Bui1dWithDF1ow

或者 jitodontfront1111111111111111JustUseJupiter 这样的钱包不是私钥碰撞生成的 应该就是直接用合法的base58公钥反正也不需要知道私钥

Any bundle containing a transaction with the jitodontfront account will be rejected by the block engine unless that transaction appears first (at index 0) in the bundle

jitodontfront意思是 包含这个账户的tx必须放在bundle第一个

这样如果bundle里面两个tx一个买sol 第二个卖sol 第二个卖出会失败

本意我估计是防止自己交易被其他人bundle进去夹，但现在被用于暗池里面识别是否是bundle

如果tx指令复杂不好解析不好穷举，那套利者bundle只有一个tx去买卖jitodontfront并不好识别

25/12/29 humidifi 升级后必须带 **Jito1 (Experimental) Vote Account** 账户应该就是一个验证者投票账户

J1to1yufRnoWn81KYg1XkTWzmKjnYSnmE2VY8DGUJ9Qv

If bundle contains any vote account jito return error:

> bundles cannot lock any vote accounts

有vote账户不让用jito，没vote账户加手续费惩罚
