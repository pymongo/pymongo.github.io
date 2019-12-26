# [19年11月下旬日报](2019/11_2/daily)

## 2019.11.26

<i class="fa fa-hashtag"></i>
Bug#内存满了

测试同学反馈说*编辑轮播图并上传*时，服务器报500错误❌，我一开始怀疑是上传图片时，服务器已有该图片导致命名重复出错 ,
后来我在本地环境测试，没有任何问题。这个问题我解决不了，于是向老大反馈。

老大凭着经验很快就找到错误原因，原来是测试服务器的内存/缓存满了。

<i class="fa fa-hashtag"></i>
Orderbook#使用jquery验证批量撤销的checkbox

关于这个技术问题，我单独写了一篇博客 [jQuery验证checkbox](2019/11_2/checkbox_jquery_validate)

<i class="fa fa-hashtag"></i>
rubymine新建rb文件有时会不识别，我单独写了一篇博客 [rubymine无法识别ruby文件](2019/11_2/rubymine_not_recognize_rb)

## 2019.11.27

<i class="fa fa-hashtag"></i>
我写的手动冻结的Bug

因为希望中途出错operation不创建，所以先new了operation再进行写入details表，最后opertion.save

但是new的时候是不会产生id的，我当时写的是last.id + 1，如果上面没有数据，就报错了

第二个不规范的地方是，没有在最外层加上事务处理

<i class="fa fa-hashtag"></i>
charts的交易对不能被写死

<i class="fa fa-hashtag"></i>
puma服务器生产环境需要手动编译css和js

昨天晚上干到11:40都没解决新写好的css样式在测试服务器上面不工作

第二天老大早上才告诉我生产环境需要手动编译css和js

相关文章[puma服务器生产环境与开发环境的区别](2019/11_2/puma_production)
