# [BIOS ECO mode](/2026/06/bios_eco_mode.md)

由于 台式机 好几年都没更换散热硅脂 + 风扇安装歪了, 散热跟不上 经常过热死机 (以前的台式机应该也是这个原因死机 要么散热要么电源问题)

于是我用笔记本电脑一样的思路 降低功耗降频压低温度 问了豆包 结果推荐改的 BIOS 没有一个对的

问了下 composor 回答找到关键信息

- 1. Disable PBO (Precision Boost Overdrive)
- 2. Enable Eco Mode (if your board has it)
- 3. Enable Cool’n’Quiet
- 4. Cap power limits manually

Eco Mode 从 105W 压低到 65W 是关键信息 开启后鸣潮就出现一次过热重启 再把鸣潮画质调低到均衡 动态模糊垂直同步吃CPU的关掉 可以一直畅玩6小时
