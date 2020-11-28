# [测试mysql对emoji的测试](/2019/12/mysql_emoji.md)

![mysql_emoji](mysql_emoji.png "mysql_emoji")

做用户聊天相关项目时，老大发现Mysql中写入emoji信息时Mysql报错，

但是又希望有聊天功能，最后用emoji库，类似微信输入`[捂脸]`就会输出相应表情,

同时通过正则表达式`[\u4e00-\u9fa5]`过滤emoji

---

Mysql8.0(5.8)开始支持全部emoji，我测试下项目用的5.7.27版本到底支不支持emoji

<i class="fa fa-hashtag"></i>
结论

Mysql5.7.27支持`Unicode 5.2`及以下标准的emoji

如 ⚡⛔⚙⚠♻☹☺❤☠
