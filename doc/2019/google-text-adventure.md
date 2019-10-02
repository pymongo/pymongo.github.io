# 谷歌的文字冒险游戏

## 进入游戏

之前看[阮一峰推特分享了](https://twitter.com/ruanyf/status/1046279819795869698)
谷歌搜索"text adventure"会在console出现文字冒险游戏

说起文字冒险游戏, 不得不提Nethack了

据推文下面评论说谷歌日本等其它地区的谷歌搜索没有这个「彩蛋」

那就用 google.com/ncr 搜索 "text adventure"吧

"ncr"的全称时no country redirect

![google-text-adventure](google-text-adventure.png "google-text-adventure")

## 游戏开始

看到console里面显示了的warning文字具有text-shadow的css效果

很好奇这是如何实现的, 如console.log('%c green%c red', 'color:green', 'color:red')中

第一个%c到第二个%之间的文字被加上'color:green'的css属性

所以最终显示结果为绿色的green加红色的red

回到游戏本身,

游戏一开始就提示"请不要输入任何账号密码"之类的

console是在browser端的, 没有任何方法可以获取用户在console内的输入

我觉得这个提示没必要

输入 yes 开始游戏

## 用firefox还是chrome玩?

这游戏明显对chrome有优化, firefox输完命令后有时会等好久, 而chrome不会

而且firefox并没有正确地显示游戏开始信息中蓝色的G字

游戏里有个命令是help, 而firefox在console里输入help会弹出MDN关于console的文档

## 游戏操作方式

首先会提示游戏操作

Commands: north, south, east, west, up, down, grab, why, inventory, use, help, exits, map, and friends.

输入help也会出现上述信息

north/south/west/east上下左右移动, up/down貌似是进入上/下层迷宫

help是显示帮组信息, exits推出游戏, why命令并没有用

- map显示地图
- grab捡起物品, use使用物品, inventory仓库(查看物品栏)

游戏任务是寻找失散的剩余5个google字母, friends显示已找到的字母

在console打个字母就能执行某些函数, 我想可能是通过重写js的toString方法

比如先定义了east对象, 然后重写east的toString行为, 实现了这个文字游戏的命令操作

其它的实现思路是python魔法方法的__get___或__repl__/__str__

## 故事背景

> A strange tingle trickles across your skin.
> You feel lightheaded and sit down.
> Feeling better you stand up again and notice your reflection in a window.
> You are still the same big blue G you've always been and you can't help but smile.
>
> But wait!  Where are your friends red o, yellow o, blue g, green l, and the always quirky red e?
> You see a statue of a metal man peeking out of a building.  A park is just across the street.

大致翻译:

一个奇怪的刺痛穿过你的皮肤, 你感到头昏眼花然后坐下.

缓过来后你站起来留意在窗户镜面上的你, 仍然是那个大蓝色的G

你感到欣慰. 但是Google剩余的5个字母去哪了?

你看到一个金属人雕像在偷看一幢建筑物

公园在街对面

## 地图要素

- 横杠-和竖杠|是迷宫的墙
- G是你的位置
- .或/或//是能走的路
- +是门, @是解谜

## 游戏攻略

**第一步**

A sidewalk circles around a palm tree.

人行道围绕着一棵棕榈树。

You see a map on a bench.  Type "grab" to pick it up.

你在长凳上看到一张地图。输入“抓取”来捡起它。


## 谷歌搜索的游戏

- chrome://dino - 恐龙奔跑游戏
- text adventure - 打开console会出现文字游戏(建议chrome下玩)
- Tic-Tac-Toe - 井字棋
- solitaire - 蜘蛛纸牌
- play snake - 贪吃蛇
- pac-man - 吃豆人
- GoogleImageSearch:atari breakout 出现雅达利的打砖块游戏(控制小平板反弹小球撞击砖块)

[参考阅读](https://searchengineland.com/the-big-list-of-google-easter-eggs-153768)

[谷歌搜索游戏汇总](https://www.maketecheasier.com/hidden-google-games/)

## Google Search Embedded tools

更多谷歌搜索彩蛋请看[维基百科](https://en.wikipedia.org/wiki/List_of_Google_Easter_eggs)

- 翻译组件: english to chinese 这种格式
- 经济曲线/股市行情: google stock/上证指数
- 汇率换算/单位/进制转化: 1000JPY to CNY
- 地图问路: from nagoya to tokyo
- 天气查询: tianjin weather
- 随机数生成器: ramdom number (generator)或 rng
- 查询颜色: 输入rgb(2,2,2)或#f2f2f2或(253,254,2)
- 函数绘图