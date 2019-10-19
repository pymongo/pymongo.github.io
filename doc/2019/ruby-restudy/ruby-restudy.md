# 再次学习Ruby

以前在soloLearn上面学过一次ruby，虽然后面mixin等学得一知半解。

很多招ruby的岗位JD上面都提到metaprogramming(元编程)，好像soloLearn的课程没有介绍

如今由于工作需要再次学习rails，回顾一下曾经用过的资料：

- 官方API文档
- 软件那些事出过的几集ruby视频
- 台湾高見龍的「為你自己學 Ruby on Rails」
- https://guides.rubyonrails.org/getting_started.html

打算就先按高見龍的Demo过一遍，等我熟悉rails后再把默认的模板引擎换成vuejs

## 试着用scoop安装rails

![01-scoop-rails](01-scoop-rails.jpg "01-scoop-rails")

果然scoop就不适合安装这种依赖复杂的cli软件，毕竟scoop安装ruby的时候就提示我要额外安装这个那个的依赖

ruby本身就对非UnixLike系统不友好，windows只能用官方推荐的【rubyInstaller】进行安装

（只要Mac还不能同时开反色和降色温，Mac还没易用的键盘宏，休想骗我回Mac）

## 学习目标

最终完成一个Rails+Vue的在线做题网站，数据库就用SQLite就行了。

试用期内要达到公司提的要求是（Rails，Vue，vim，标准指法，普通话）。

关于标准指法，根据typeclub.com的测试结果我标准指法只有7WPM的速度，而同样100%正确率自己习惯的打法速度在50-60WPM之间，而且我能盲打很熟悉每个键的位置，参考[v2ex.com/t/221161](https://www.v2ex.com/t/221161)，指法问题先放下。

## ruby运算回顾

puts/print区别上前者有换行，语法上二者像python2的print

*ruby的多行注释是在=begin和=end之间

★ruby常量ID以大写字母开头

nil≈null,nil is a instance of @@NilClass  
没有返回值的表达式会在irb上显示=>nil

.reverse! 逆序并改变值 使用驚嘆號，通常是表示使用這個方法可能會有「副作用」  
.include?、.empty?、.gsub#replace

不想要地板除的话，就让被除数或除数加个.0成小数就行

实现列表追加，可以用<< 或 + 或 逻辑或|

### [reduce]ruby从1加到100

(1..100).to_a.each ==  [*1..100].each

> puts [*1..100].reduce(:+)

