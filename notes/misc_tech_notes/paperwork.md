# 我的文案(paperwork)创作

## 《Rust唠嗑室》第14期直播预告

主讲人: 吴翱翔
内容: 树莓派和arduino是两个最流行的开源硬件，Rust语言近年来也逐渐支持arduino的AVR架构。
本期嘉宾将以直播敲代码形式给大家分享下用Rust语言进行硬件编程的体验，
内容包括用Rust编写74HC595芯片驱动，流水灯、蜂鸣器、七段数码管时钟、拨码开关、轻触按钮等电子元器件/芯片驱动的代码。

嘉宾用live coding+IP摄像头设备，为大家呈现每敲一段Rust代码后，摄像头中的树莓派硬件会发生哪些变化，演示从零到敲代码到绚丽流水灯显示的完整过程，并讲解其中的原理。

## RustConf2020 topic

Topic 中文名称: 浅谈Rust在算法题和竞赛中的应用 
Topic 英文名称: Play Rust in programming competition
Topic 简介: Rust工程性和开发效率会给codeforces上刷算法题或leetcode周赛竞赛中的带来哪些优势？
Speaker 名称: 吴翱翔
Speaker 简介: tokio-postgres,sqlx,bigdecimal-rs等库的代码贡献者，saks库的作者，leetcode刷题量400+
Speaker 公司: Rust中文社区
Speaker Title: Rust中文社区

## Rust大会2020的收获总结:

Rust大会2020的收获:

- 用户态存储优化io_uring, spdk.io(当有dpdk)
- ClickHouse列缓存db
- HashMap缓存不友好
- RISC-V用插件扩展指令集，可禁用MMU
- 私有crates.io和cargo yank

## 我对知乎上有人点评我topic的回复

作为该topic的speaker，首先很感谢您这么细致观看我的分享内容，这也是对我工作的认可。

1. PeekableIterator
这是用来解决特定问题的数据结构，我在工作中仅用过一次，leetcode上也有一题让你实现PeekableIterator(可惜不支持Rust)

4. IpAddr
这个题不能用标准库解析IP地址的原因是，leetcode官方说明了这题的输入「不是标准POSIX socket地址格式」
我这里主要演示Rust的模式匹配写法比较优雅

5. Rust调用C函数
虽然leetcode仅允许rand一个第三方库，但是我更希望题解不依赖任何第三方库，这样就能在坐飞机时离线编译
Rust调用汇编和C语言解题也算我准备这个topic中的一些亮点，因为我看了其它Rust的提交记录，没有人在leetcode上用Rust调用C语言函数
希望社区能发掘更多Rust调用C语言解题的题解

6. String::into_bytes
leetcode/codeforces上面的字符串基本都是字母+数字(ASCII码范围内)，用Vec<u8>的读写效率比String高

8. 其实用#[deny(warnings)]让clippy警告时编译不通过用的更多

也感谢您在几道题中给出了更简短的题解，我的分享里还有个亮点是codeforces这种传统ACM从stdin中读数据的刷题/竞赛网站要怎样进行单元测试。
我个人也希望leetcode周赛排行榜上能看到Rust的提交，虽然我每次周赛只能完成2-3道题，作为没受过系统的算法竞赛训练工作后才刷题的我，周赛就只能止步于1000多名了

## 产品评价

### 荣耀magicbook_pro_2020_r5

玩Linux/Ubuntu操作系统的可以放心购买，我装了Arch Linux(manjaro)以后驱动正常系统流畅(前置摄像头和指纹解锁的linux驱动还没测)
由于主板不支持MBR引导，所以不能将ubuntu系统iso解压到FAT格式的U盘，建议用开源的etcher制作装机启动盘

我买的是R5集显款，我装了manjaro系统后编译rust-analyzer源码比iMac快3倍，玩生化危机5能最高画质，玩生化危机6/魔兽/守望不卡
为了超窄边16寸大屏显示设计成升降式摄像头非常有创意我很喜欢，喇叭面积是我见过笔记本中最大的

能以较低价格买到这么好的配置+屏幕+音箱，除了屏幕不如苹果电脑4k屏，4000的价格比苹果2020款的M1 Air的硬件配置好太多了。
本来我还在犹豫7999的苹果M1 air还是荣耀笔记本，现在上手linux操作系统的荣耀笔记本后体验比苹果电脑+苹果系统好太多了，
苹果的C/C++工具链真是残缺，没有ldd查看动态链接信息，也没有ar打包静态链接库，苹果系统还封闭，不适合程序员深入系统底层

## tweet文案

### recaptcha踩坑记

```
recaptcha密钥是绑定client域名的，同事想从两个域名A和B访问登录接口(我们在登录接口加的recaptcha验证码)
我想当然的以为拿token和域名A密钥调谷歌API，如果失败就拿token和域名B密钥再调一次
我测试时发现有防重入机制，token用了一次就失效了(也就是API文档的ErrorCode: timeout-or-duplicate)
```

```
解决办法是toml配置文件把recaptcha的配置项改成数组类型，这样就可以支持多组域名+密钥的配置(可能网站推广时为了SEO前端会有多个域名)，
然后启动时将recaptcha配置转成HashMap，根据client请求的Origin/Referrer去查询相应的密钥

为了测试我一天点了上百次recaptcha图片验证码:(
```

### vec_vec!宏

参考了warycat/rustgym的vec_vec_i32!宏源码以后，我实现了一个支持泛型能解析并并生成二维数组的vec_vec!宏
我之前尝试过宏入参是expr或stmt类型的metavariable，无法通过编译，今天发现将二维数组中每个子数组看做成token_tree就能实现了二维数组解析了

### 荣耀指纹锁和摄像头驱动问题

wifi和升降式摄像头都是装好系统就能用，
用VLC打开升降式前置摄像头能正常工作。
至于指纹解锁，我用的KDE 5.20还没相关设置，不想下第三方的Fingerprint，等5.21版本内置指纹设置再试试。
或者有机会我再装个win10或Ubuntu试试指纹解锁
我笔记本大部分时间都是合起来然后外接显示器，想用指纹锁还得掀开笔记本，没用过指纹解锁

### KDE emacs shortcuts

KDE好像没办法全局emacs like keymap，从mac转linux不太习惯不能用Ctrl+F移动光标了
例如chrome输入网址后没法按Ctrl+N/P上下挑选了，krunner也不能像spotlight按Ctrl+N往下挑选
加了gtk-key-theme-name="Emacs"的配置也没用
只有vscode和idea可以改成emacs或macOS的keymap，其它应用就没办法了

自从同事教会我用手掌按左Ctrl后(英雄联盟加点时小指指腹按Ctrl,小指按q,这样能最快加完q并释放q技能)，
我就觉得Ctrl是最好按的组合键，手掌稍微往下就按上
如果caps改键ctrl反而违反标准指法，只能小指按caps,无名指按q

