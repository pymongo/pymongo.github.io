# [测试mysql对emoji的测试](2019/12_1/mysql_emoji.md)

做用户聊天相关项目时，老大发现Mysql中写入emoji信息时Mysql报错，

但是又希望有聊天功能，最后用emoji库，类似微信输入`[捂脸]`就会输出相应表情,

同时通过正则表达式`[\u4e00-\u9fa5]`过滤emoji

---

Mysql8.0(5.8)开始支持全部emoji，我测试下项目用的5.7.27版本到底支不支持emoji

<i class="fa fa-hashtag mytitle"></i>
结论

Mysql5.7.27支持`Unicode 5.2`及以下标准的emoji

如 ⚡⛔⚙⚠♻☹☺❤☠


<p>请勿在汇款备注内填写比特币，BTC，OTC等任何数字币有关字眼，防止您的汇款被银行拦截</p><br>
<p><span>银行账号</span>：&nbsp;&nbsp;<span style="font-family:'Helvetica Neue',serif;color:#454545">xxxx xxxx xxxx xxxx</span></p>
<p>支付宝账号：<span style="font-family:'Helvetica Neue';color:#454545">xxx xxxx xxxx</span></p>
<p>微信账号：&nbsp;&nbsp;<span style="font-family:'Helvetica Neue';color:#454545">xxx xxxx xxxx</span></p>
<p style="">下单后可以直接加我微信跟我联系，我会尽快回复</p>
