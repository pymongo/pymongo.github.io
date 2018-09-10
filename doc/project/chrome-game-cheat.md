<img src="/img/chrome-game-cheat/cover.png">

没网时，谷歌浏览器会出现一个恐龙奔跑游戏

或打开 [chrome://dino/](chrome://dino/) 进入游戏

操作很简单，跳跃或下蹲避开障碍物，按Alt可以暂停

那么如何在这个小游戏中作弊呢？

## 审查网页

这个游戏的动画引擎是canvas

<img src="/img/chrome-game-cheat/canvas.png">

由于网页游戏(除了flash)的逻辑是用js实现，

那我就在键盘事件中设置一个断点，就能从茫茫多的js代码中找到想要的函数

<img src="/img/chrome-game-cheat/inspect.gif">

结果发现在Runner对象内部处理掉键盘事件e

## 找下Runner Object的源码

js的类以前都是用函数实现，而js的函数有个toString方法看源码

<img src="/img/chrome-game-cheat/runner-tostring.png">

Runner函数源码一开始就是「单例模式」实现部分，

注释上的Singleton就是单例的意思

所以用Runner.instance_就能获取当前游戏对象

不过Runner.toString出来的源码有点少，很可能不是完整的

继续想办法看看页面的js源码在哪，结果发现来自VM...

<img src="/img/chrome-game-cheat/VM.png">

先阅读下VM前缀是什么意思 [VM file from javascript](https://stackoverflow.com/questions/17367560/chrome-development-tool-vm-file-from-javascript)

VM前缀的js代码可能在以下地方

- 开发者工具的console内
- eval
- script标签内
- Chrome内部网页

排除前两种可能，很快在第四个script标签内找到了游戏源码

<img src="/img/chrome-game-cheat/source.png">

从这样优秀的源码中还是能学到不少新东西

结果源码太长还是看不全，只好另存为html文件用IDE打开看

## 游戏作弊

如何让小恐龙"无敌"，碰到敌人也不死掉？

原来触发gameover后会结束游戏，现在只要把gameover函数改为空

即便碰到障碍物触发了gameover也会当做无事发生继续游戏

<img src="/img/chrome-game-cheat/gameover.png">

```javascript
// 存储旧的gameover Handler以便手动结束游戏
var gameoverOld = Runner.instance_.gameOver;

Runner.instance_.gameOver = () => undefined;
```

<img src="/img/chrome-game-cheat/cheat.gif">

参考文章

[chrome-dino-hack](https://mathewsachin.github.io/blog/2016/11/05/chrome-dino-hack.html)
