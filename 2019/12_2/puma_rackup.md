# [puma与rackup服务器](/2019/12_2/puma_rackup.md)

很奇怪的是，使用rackup启动服务器时不能存在`config/puma.rb`文件

否则会报错`NoMethodFound...threads`

rackup使用puma服务器：

`bundle exec rackup config.ru -s puma`

!> 然而rackup默认就是用puma服务器的single mode

我使用了公司测试服务器上的puma脚本将puma运行在cluster mode

结果服务器开启/重启速度跟rackup默认puma差不多，也是光标闪烁5-6下完成重启

不管怎么说puma总比之前用的guard服务器快多了，guard可是4秒多才重启完
