# [amd超频的尝试](/2021/05/amd_overclock.md)

板U套: ASUS_X570_PLUS + 5900X

![](amd_compile_pbo.gif)

很多人说主板的PBO设置默认的Auto其实就是Disable

我看在我这X570高端主板上，似乎默认配置就会从3.7超频到4.4

照着知乎上那种解锁功率墙等等的超频配置，编译代码的速度也就提升1%

而且会导致CPU温度达到86度，主板默认配置下不会超过80度的

加上lld的优化后其实编译ra代码可以杀进28秒内，已经够快了，超频也就快1秒多没必要

因为我用的不是360水冷所以散热跟不上PBO带来的性能提升也有限

¶ reference:
- <https://zhuanlan.zhihu.com/p/356507791>
- <https://www.bilibili.com/read/cv4583366/>
- <https://www.techpowerup.com/forums/threads/amd-curve-optimizer-any-guides-experience.275640/page-2>
