# Web端控制树莓派IO口

## 兴趣的来源

以前在Youtube看些智能硬件的视频, 非常喜欢网页控制硬件的设计, 可惜当时不懂前后端技术, 也没法自己动手做

让我比较印象深刻的是onion的Single Board Computer, 可以在Web UI的Node.Red软件思维导图一般画流程控制, LabVIEW结合Arduino的桌面窗口程序控制硬件IO口, 有点智能家居的意思

## 终于找到实现的方法

我在看GreatScott的树莓派的时候看到他在terminal输入gpio命令就能点亮一个小灯

恰好我那时也在soloLearn学完PHP课程, 想起PHP可以在CGI脚本里执行命令行的gpio命令, 于是在大三上学期开始做

[wiringpi](http://wiringpi.com/the-gpio-utility/)

## 成果演示

![rpi-gpio](rpi-gpio.gif "rpi-gpio")

## 程序流程思路

前端页面是一个按钮 [https://www.w3schools.com/howto/howto_css_switch.asp](create a toggle switch)

用flask做框架, 前端点击相应按钮时执行 gpio toggle [引脚]的命令

## 后续工作

微信公众号+VPS实现微信公众号发开灯即可开灯
