# [页面置换算法](/2023/08/page_replacement.md)

- 局部页面置换算法: 最优,FIFO,LRU,时钟,LFU
- 全局页面置换算法: 工作集,缺页率,抖动和负载控制
- 面向缓存的页替换算法: FBR,LRU-K 2Q,LIRS

覆盖/交换虚拟内存的区别是，覆盖是程序员精确控制地址的，而交换是操作系统控制管理的，二者都是层次存储的思路将不常用的数据放到外存

## 最优页面置换算法
毕竟 CPU 速度远快于内存所以未来的指令会被缓存到三级缓存中，

发生缺页的时候，CPU 看看缓存中"未来若干个指令"中不会用到哪个内存页，就淘汰掉该页

优点是性能好，缺点是 CPU 无法准确预测程序的分支

## FIFO 置换算法
缺页时把链表头部也就是内存中驻留最久的页面置换到硬盘，新页面从硬盘中读取到链表尾部

优点是实现简单，缺点是性能很差，还有 belady 现象(听起来有点像锁饥饿问题)

缺点解决办法是 FIFO 算法结合其他算法一起使用

## 重点: belady 现象
物理内存增加后内存总页数增加，缺页率反而也增加，也就是缓存命中率反而更低了

LRU、LFU、OPT 均为堆栈类算法，FIFO、Clock 为非堆栈类算法，只有非堆栈类才会出现 Belady 现象

~~例如 FIFO 容量为 2 结果应用程序页面 1 和 页面 3 反复交替访问，这样每次访问都是缺页~~

## LRU 置换(Linux 默认采用)
Least Recent Used

缺页时置换掉过去长时间内都没有访问的页面

优点是最优算法的近似性能好，缺点是仍然非常复杂(看 leetcode LRU 题解就知道了)

除了链表实现还有中活动页面栈的实现，访问页面的时候入栈，同时遍历整个栈删掉跟刚刚入栈的重复元素，栈满的时候移除栈底元素

## clock/Second-Chance 置换算法
page table entry 增加一个访问位(RISC-V MMU 会自动更新该位)

FIFO+LRU 的结合

缺页的时候，从环形链表开始遍历太久未被访问的页面去置换，遍历的时候遇到访问位是 1 的就清零，然后遇到第一个访问位为零的页(就是被上次遍历清零)就拿去置换(有点像一些算法题)

由于是环形链表遍历，所以如果所有页面都是访问标志 1 第一轮遍历就会全部置零，第二轮遍历就会返回第一个节点，退出遍历

为什么会命名为 clock 算法因为环形链表的遍历过程就是一个钟表一样

### 针对干净页/脏页的改进
如果置换的页面发生过写入操作，则需要同步的写回到硬盘中，发生过写入的页面也叫脏页，因此 clock 算法的改进是优先把干净页置换到内存中，因为硬盘可能提前缓存过该页面，所以不会发生任何 IO 操作

page table entry 增加一个修改位，如果页面发生写入修改置为 1，置换的时候优先置换掉只有读取操作的页面()

## LFU 置换算法
访问标志是多个 bit 溢出就右移

## 工作集置换策略/算法
工作集值得是进程某段时间内访问的内存页面编号集合，算法需要硬件支持，难以实现，略过

## 缺页率置换策略/算法
类似 TCP 拥塞控制的感觉，如果缺页率过高，就动态调大进程的物理内存，反之降低

---

## 树状覆盖载入
例如嵌入式开发场景内存不到 1kb

有两个依赖库一个 500kb 一个 256kb, 可以程序员手工控制需要使用模块一的时候将库从 ROM/硬盘 写入到内存中，

需要用模块二的时候再从 ROM 写入到原有位置，因为使用模块二的时候模块一不会被读取，因此模块一二共用一段内存

因此程序员必须严谨列出模块代码的调用树，禁止代码出现跨树调用，每次只将树根节点的一个分支覆盖载入到内存中

## kernel page table isolation