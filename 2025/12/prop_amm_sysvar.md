# [prop amm sysvar](/2025/12/prop_amm_sysvar.md)

为什么暗池swap都要传sysvarInstrution账户? breakpoint2025的演讲 <https://www.youtube.com/watch?v=_VPQHv5WRP4> <https://x.com/chrischang43/status/2000651609743982877>

暗池有这样的需求:
1. 识别特定交易进行手续费惩罚或者让利
2. 拒绝bot原子套利交易又买又卖

从jup网页聚合器路由过来的交易让利让点3bp jup每日会返佣给暗池做市商，这样即便ultra v3收5bp平台费hum让利6bp也能有更优价格

sysvarInst类似【反射】可以拿到整个transaction信息

- [Feature: Instructions Sysvar Support](https://github.com/anza-xyz/pinocchio/pull/106/files)
- sysvar::instructions::{load_current_index_checked, load_instruction_at_checked}

bot又进化了 既然你读我整个tx有没有三角套利有买有卖，那我用jito bundle把买卖隔离成两个独立的tx，加上fake tip或者临时生成钱包gas/tip代付，还是挺难检测的吧?

<https://docs.rs/solana-program/latest/solana_program/sysvar/instructions/index.html>
