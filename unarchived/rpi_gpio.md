# [智能家居 - 平板电脑控制电灯](/unarchived/rpi_gpio.md)

> [!TIP|label:Surface平板电脑控制电灯]
> 如图，把电灯换成继电器就能控制任意220V的家用电器了


![rpi_gpio](rpi_gpio.gif "rpi_gpio")

## 如何实现

树莓派RaspberryPi能在主流操作系统如Ubuntu上

!> 直接控制芯片引脚电压/电平

通过Raspbian系统内置的[WiringPi](http://wiringpi.com/the-gpio-utility/)库，可通过shell或任意编程语言直接修改芯片GPIO的电平

当时我还没学Python的Flask框架，就用自认为最简单的PHP做后端

前端网页就只有红色和绿色两个按钮，按一下就发送一个Ajax请求给PHP处理

通过网线相连让平板电脑和树莓派处于同一网段，最后平板电脑访问下树莓派上的相应PHP页面即可。

---

<i class="fa fa-hashtag"></i>
后记

使用python或php的GPIO API真的少，若想改变PWM频率等操作还是老老实实用C语言吧

毕竟C语言能直接修改寄存器从而改变输出电平

## 再加点需求

TODO 微信公众号+VPS实现微信公众号/小程序远程控制
