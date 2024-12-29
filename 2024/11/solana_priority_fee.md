# [优先费与快速上链](/2024/11/solana_priority_fee.md)

如何调优先费让交易快速上链——从agave源码剖析为什么jito适合套利?什么时候用优先费什么时候用jito?

---

可否量化SOL网络拥堵的指标区调整优先费提高上链速度呢？判断SOL网络拥堵的指标, SOL 域名解析商 sns.id 网页上右上角显示 `Congested network`, 从区块浏览器上看TPS 普遍都有 4000+ 但 true TPS 真正属于用户交易的其实就只有几百 TPS，其余的 TPS 都是网络共识层投票等。

网络拥堵时，交易员/开发者/套利者等发出去的交易常常等很久都不上链，也听space上开发者抱怨交易很难上链或者优先费用卷的很高，如何利用**优先费用(priority fee)**或者**jito小费(jito tips)**机制提高交易成功率和上链速度呢?

## 优先费用机制

1. 交易带 SetComputeUnitPrice 指令才启用 优先费机制
2. 交易带 SetComputeUnitPrice 但没 SetComputeUnitLimit 指令 默认按 **20万 ComputeUnitLimit/每条指令**
3. 交易同时带 CU price/limit 两个指令(不管指令顺序)，不管交易成功或失败都收取 price*limit 的优先费用

ComputeUnit往后简称为CU, [sol官方文档 how-to-use-priority-fees](https://solana.com/developers/guides/advanced/how-to-use-priority-fees) 中有个[规则2的示例交易(solscan)](https://solscan.io/tx/5scDyuiiEbLxjLUww3APE9X7i8LE3H63unzonUwMG7s2htpoAGG17sgRsNAhR1zVs6NQAnZeRVemVbkAct5myi17)

文档说 `set the Compute Unit Limit to 300 CUs while also adding a priority fee of 20000 micro-lamports`

> 应该是这篇文章里面的tx太旧了，是以前验证者节点代码，最新的agave源码中如果是内置指令没有加CUlimit也会自动设置成150, 第三方指令就20万

实际上这个交易忘了设置 CU limit 变成默认的 20万 CU limit 每条指令(最新验证者节点这个交易CU limit应该自动是300 可能过于古老了) 所以收取了每笔交易基本费用，注意CU price单位是micro lamports要乘以1e-6转换成SOL_lamports per CU的量纲

> 5000 + (20000*1e-6 * 200000) = 9000 lamports SOL = 0.000009SOL

交易费用=5000lamports基础费+账户租金费/开户费+优先费用, 优先费用总值的竞价排名决定了交易在验证者出块的优先级

源码在 agave(solana 2.0之后改名成 agave 项目继续维护了，原github地址不更新) 的 cost-model crate 中可以看到常量 DEFAULT_INSTRUCTION_COMPUTE_UNIT_LIMIT 就是 20万

```rust
    fn get_transaction_cost(
        transaction: &impl TransactionWithMeta,
        feature_set: &FeatureSet,
    ) -> (u64, u64, u64) {
        let mut programs_execution_costs = 0u64;
        let mut compute_unit_limit_is_set = false;
        let mut has_user_space_instructions = false;
        for (program_id, instruction) in transaction.program_instructions_iter() {
            let ix_execution_cost =
                if let Some(builtin_cost) = BUILTIN_INSTRUCTION_COSTS.get(program_id) {
                    *builtin_cost
                } else {
                    has_user_space_instructions = true;
                    u64::from(DEFAULT_INSTRUCTION_COMPUTE_UNIT_LIMIT)
                };
            programs_execution_costs = programs_execution_costs
                .saturating_add(ix_execution_cost)
                .min(u64::from(MAX_COMPUTE_UNIT_LIMIT));
            if compute_budget::check_id(program_id) {
                if let Ok(ComputeBudgetInstruction::SetComputeUnitLimit(_)) =
                    try_from_slice_unchecked(instruction.data)
```

再看一个同时设置了CU price和limit的例子: <https://solscan.io/tx/BcBCS61y3GpYCHVzUZ3KK7v1M7PgYqNM8oyqx3oLq7XcxaYDW5SH1GQqvL5pkR91jypxh9sPDpztMby32oxEnre>

agave 源码中 solana_compute_budget_program DEFAULT_COMPUTE_UNITS 是 150, 设置CU limit/price和转账都是150

上述交易CU limit设置了3000，交易有2个设置CU的指令和18次SOL转账的指令，加起来刚好是(2+18)*150=3000 CU

> 10000*1e-6 * 3000 = 300 lamports

## CU limit 如何设置

**即便交易只用了300CU但设置了20万的CU limit**(如上述例子1的tx), 也是按照CU limit 20万收取优先费用

所以交易中尽可能设置更低的CU Limit，而且根据[helius 文档](https://www.helius.dev/blog/how-to-land-transactions-on-solana#compute-units)
CULimit越低的交易上链的优先级更大

常见的交易指令中消耗的 CU

- transfer/SetCU: 150
- 智能合约部署: 约2500-3000
- CloseAccount: 2916
- token transfer: 4644(不需要开户时)
- create ATA account(token开户): 约30000
- raydium AMM swap: 约33000-40000
- jupiter swap: 约100000-400000

像jup swap这样不确定的CU消耗 推荐用simulate rpc模拟执行获取CU消耗

## 优先费用价格CU price设置算法

1. 交易预期利润的60%除以CU limit得到单价的套利贿赂矿工算法
2. Helius Priority Fee API 的推荐
3. rpc getRecentPrioritizationFees
4. triton Improved Priority Fees API
5. jupiter,raydium,metaora这样的产品也内置了优先费用的计算，无需开发者处理

原版 rpc 优先费 API 返回的是某个智能合约地址最近150区块交易中的最小值(at least one successfully landed)

其实更推荐用 triton 增强型优先费API能查询到某智能合约最近大伙给的优先费的中位数

一般网络拥堵的时候我个人经验是 jupiter TURBO 等级的优先费用都要给到0.2u~0.4u不等

> **SOL跟EVM不同的是，EVM如果交易失败了 收取的是 gasPrice * gasUsed(实际消耗的CU)**

那么问题来了，对于一个预期利润是 10SOL 的套利交易，拿出了80%预期利润8SOL的优先费用贿赂矿工

但是交易因为滑点过大没抢单成功，**交易失败了也要支付8SOL的优先费用**，是非常昂贵的成本了

## 为套利者而生的jito

jito的出现就解决了这个问题，jito的交易不需要设置优先费用CU price的指令(CU limit还是建议要)

而是让交易最后加一个给jito 8个小费地址随机选一个转账的指令，为什么要随机选一个呢

如果大伙都往第一个小费地址打钱，8个地址随机选一个可以提高吞吐量同时有8个jito小费指令可并行执行

所以发送给jito的交易失败发生回滚的话，最后一条小费指令不会执行，也就损失5000lamports的基础交易费用

24/12/16 jito auction 规则更新(现在跟优先费类似也看cuLimit了) tip-based prioritization to a tip-per-CU prioritization.

### jito的竞争者nextblock.io

### **bloXroute**加速上链服务

很多bot的交易不直接发给jito，而是通过bloXroute转发给jito。因为bloXroute有一个super bundle的功能，能打包不冲突的交易，bundle的tip也给的高，所以比直接发jito速度更快。

bloXroute也是jito最大的合作伙伴之一，在jito那里有很高的账户等级；tip给的高，只是快速上链的条件之一。其实还有其他一些基础设施上的配置，包括全球的节点布置，合作节点，网络拓扑优化等等

据说主要是交易机器人和一些dex,做市商等采购 bloXroute 服务，我没用过就不评价了

## 什么时候用jito什么时候用优先费

§ 适用于jito加速交易的业务
1. 套利交易
2. 狙击pump/raydium等开盘
3. 防夹
3. 价格波动大的LP建仓
4. 失败率高允许重试有希望快点上链的业务

笔者有次LP建仓发交易就说价格波动导致tick滑点变动交易失败，连续失败4-5次 每次亏损0.4$的优先费用 如果用jito不断重试交易就不必亏这么多了

§ 适用于优先费用加速交易的业务
1. memecoin swap交易
2. 快点转账

§ 既不要jito也不要优先费的业务
1. 转账(钱包软件基本不给优先费)
2. 智能合约部署
3. LP超出区间了移除流动性等不是很急的业务

智能合约部署我的经验是推荐用 aws免费节点+helius免费rpc 上传/部署智能合约

项目不急着上线失败就重试几次(急的话deploy可加优先费用的命令行参数)，失败的话会出现一些 program buffer 占用资金，稍后 solana program close 关掉后就能回收SOL了

### 谁当leader就给谁发

由于SOL网络中当前epoch POS的leader顺序是确定的，也可以预测下个leader是jito的节点就给jito发交易，如果是helius/triton节点就用优先费给他们发

可以用 <https://solanabeach.io/> 工具, 或者 rpc 方法 **getLeaderSchedule** 获取当前leader

solanabeach工具可见大部分验证者都在欧洲法兰克福包括helius，美西美东也有一些(毕竟美国各大交易所不准KYC，幻影钱包和moonshot就是美国版币安)，东京很少

jito/agave源码中 TPU 客户端发送交易，会查询当前leader节点

```rust
pub async fn try_send_write_transaction() {
    let leaders = self
        .leader_tpu_service
        .unique_leader_tpu_sockets(self.fanout_slots)
}
```

还有源码找下 `if is_leader_slot` 和 bench-tps crate

### both/mixed广播方式
jupiter/metaora 可以选both方式同时给jito和非jito发交易，具体怎么实现的？

由于jito的bundle交易，捆绑5笔，只给一笔小费，或者给5笔小费都行

我的理解是先签名一个带优先费用的交易同时发给jito和helius,发jito的多捆绑一个打小费的交易

还有一种思路**nonceAccount**同时签名**两个交易一个发jito一个发helius**，一个成功另一个自然因为nonce无效而失败

## swqos机制加速上链

swqos简单说就是质押量越大的验证者节点，在下个区块出块中能提交给leader节点的交易数更多，所以走质押量更大的节点rpc上链更快

[听solayer在space说](https://x.com/Solana_zh/status/1856684090399117736)
要把swqos加速上链的机制做成restaking奖励，用户质押给项目方更多SOL，项目的上链速度更快体验更好，项目方应该奖励给质押用户额外奖励这样的经济模型

swqos节点基本是被triton,helius这样的大户厂商垄断了，quicknode这样的知名厂商也没有，~~所以solayer能否打破这种垄断呢(支持华语区项目打破垄断)~~

由于triton服务不对外公开销售了，所以也就只能用helius付费的staked connection rpc消耗的额度是普通rpc的50倍

nextblock.io 有 Dedicated SWQoS 服务看上去比 helius staked-connection 好

## 如何确认交易成功/交易重试

由于solana网络拥堵时，发出去的交易可能被rpc节点丢弃没有发成功给leader节点了，或者等很久很久才上链，因此重试策略推荐阅读 triton 这篇文章 <https://docs.triton.one/chains/solana/sending-txs>

1. 计算下签名交易用的blockhash还有多久过期
1. ws订阅交易的signature
2. 发送交易
3. 每隔一段时间获取交易状态，定时重发交易

直到http轮询交易成功或者ws推送交易成功

由于笔者做的是套利业务对时效性要求极高(行情过几秒后可能滑点巨大)，所以我的做法是交易中插入一条超时5s指令

ws+http轮询交易状态超过5s就认为是超时了，这样交易很久之后才上链会因为超时而失败
