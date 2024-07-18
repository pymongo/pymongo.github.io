# [SOL 数据租金](/2024/07/solana_rent_epoch.md)

储蓄卡/信用卡的每年不消费的话要交年费，例如储值1500就免除今年的年费。
信用卡的年费机制让我联想到 solana 的 rent-exempt 机制
SOL 作为一个"分布式数据库"，存储数据是要交「租金」的，代码要算出数据的长度交租
租金不是立即扣除，而是锁定在账户上，过段时间扣除，不补充租金的话数据就被冻结

银行免除储值较高储户的年费，激励储户充钱防止挤兑提高存款准备金的一个手段
solana 对持有 SOL 的用户奖励一定的租金豁免额度，可以免除每年数据租金，奖励持有者的机制
当然 staking 的奖励也能抵扣租金和交易费用
数据租金很好的给分布式数据库减负，但就76kb的代码收我80$租金太贵了

(让我联想到TRON能量质押奖励点数可以抵扣GAS费用)

我理解错了，最低租金豁免门槛指的是"锁定"一定数量的金钱，可以永久存储数据，rent_epoch 字段会设置成 u64::MAX

如果存储数据资金被挪走部分，会像期货/永续合约那样定时从维持保证金中收取利息/资金费/租金，维持保证金太低就爆仓/数据冻结

SOL 文档说基于啥的存储硬件成本越来越低，租金会随摩尔定律或硬件

https://solana.com/docs/terminology#rent-exempt

> Accounts that maintain a minimum lamport balance that is proportional to the amount of data stored on the account. All newly created accounts are stored on-chain permanently until the account is closed. It is not possible to create an account that falls below the rent exemption threshold.

示例代码上都是直接转最小豁免租金的钱

```
Program Id                                   | Slot      | Authority                                    | Balance
8xubajzX923ZXpUzbyTcXuxy9QcMbrUCosm4H6ZRtTtk | 312304419 | EsQczJECiL2QXYofUT9Cs9c6BuujdEYcmRnhuhUbFr4H | 0.33901464 SOL
GXScYf8mQbRUPYzjgthe3idqqvfqPoYKbBe3vHmdT3dS | 312479425 | EsQczJECiL2QXYofUT9Cs9c6BuujdEYcmRnhuhUbFr4H | 0.5365116 SOL

w@w:~$ p solana epoch-info
ProxyChains-3.1 (http://proxychains.sf.net)

Block height: 300746209
Slot: 312513815
Epoch: 723
Transaction Count: 14077900097
Epoch Slot Range: [312336000..312768000)
Epoch Completed Percent: 41.161%
Epoch Completed Slots: 177815/432000 (254185 remaining)
Epoch Completed Time: 18h 34m 17s/1day 21h 2m 56s (1day 2h 28m 39s remaining)

root@lb1:~/solana_client_example# solana account 8xubajzX923ZXpUzbyTcXuxy9QcMbrUCosm4H6ZRtTtk

Public Key: 8xubajzX923ZXpUzbyTcXuxy9QcMbrUCosm4H6ZRtTtk
Balance: 0.00114144 SOL
Owner: BPFLoaderUpgradeab1e11111111111111111111111
Executable: true
Rent Epoch: 18446744073709551615

root@lb1:~# solana transfer EsQczJECiL2QXYofUT9Cs9c6BuujdEYcmRnhuhUbFr4H 0.1 --config greeting_account-keypair.json  --allow-unfunded-recipient
Error: Account EsQczJECiL2QXYofUT9Cs9c6BuujdEYcmRnhuhUbFr4H has insufficient funds for spend (0.1 SOL) + fee (0.000005 SOL)
root@lb1:~# solana balance --config greeting_account-keypair.json
0 SOL
```

尝试转走合约账户上面的钱

```
root@lb1:~# solana-keygen pubkey greeting_account-keypair.json
8xubajzX923ZXpUzbyTcXuxy9QcMbrUCosm4H6ZRtTtk
root@lb1:~# solana balance --keypair greeting_account-keypair.json
0.00114144 SOL
root@lb1:~# solana transfer -k greeting_account-keypair.json EsQczJECiL2QXYofUT9Cs9c6BuujdEYcmRnhuhUbFr4H 0.0003
Error: RPC response error -32002: Transaction simulation failed: This account may not be used to pay transaction fees
```

好吧合约账户不能转账，就当solana上面交钱存储数据是永久的好了
