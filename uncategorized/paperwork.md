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

3. 相比

## mac keymap vscode+ra and intellij+rust

vscode idea
Cmd+T
Cmd+.(quick_fix/code_action) Alt+Enter

## tweet文案

### recaptcha踩坑记

```
recaptcha密钥是绑定client域名的，同事想从两个域名A和B访问登录接口(我们在登录接口加的recaptcha验证码)
我想当然的以为拿token和域名A密钥调谷歌API，如果失败就拿token和域名B密钥再调一次
我测试时发现有防重入机制，token用了一次就失效了(也就是API文档的ErrorCode: timeout-or-duplicate)
```

```
解决办法是toml配置文件把recaptcha的配置项改成数组类型，这样就可以支持多组域名+密钥的配置(可能网站推广时为了SEO前端会有多个域名)，
然后启动时将recaptcha配置转成HashMap，根据client请求的Origin/Referer去查询相应的密钥

为了测试我一天点了上百次recaptcha图片验证码:(
```

### vec_vec!宏

参考了warycat/rustgym的vec_vec_i32!宏源码以后，我实现了一个支持泛型能解析并并生成二维数组的vec_vec!宏
我之前尝试过宏入参是expr或stmt类型的metavariable，无法通过编译，今天发现将二维数组中每个子数组看做成token_tree就能实现了二维数组解析了

### 我租房的邻居是个餐厅

不要租成都天鹅湖25号楼3单元1803附近的房，这户是个「餐厅」
午餐晚餐时大门常开很多人的进出吃饭，吵得没法午睡那我就不午睡了
之前7-8点买菜切菜我已经忍了，最近两周天天5-6点推着大推车买菜送菜，推车声和敲门声特别大，
特别是切排骨时震得我屋里的门都在抖，今早吵到旁边邻居都出来骂了，我也受不了准备搬走了

租房要是有试用期就好？试住一周才知道邻居吵不吵，我本以为整租能比合租隔断能安静很多，却倒霉遇到了做餐厅的邻居
我想起之前住北京南湖东园的同事，他说房子白天时客厅厨房会租给农名工做饭和休息，这样房租能便宜好几百，然后同事经常抱怨那些人做完饭后地板脏也不做卫生
我已跟链家沟通换租了，受不了
