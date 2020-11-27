# [puma服务器生产环境与开发环境的区别](/2019/11/puma_production.md)

<i class="fa fa-hashtag"></i>
不会自动编译css和js代码

例如修改了application.scss，需要执行`recompile`脚本编译css和js

```
rm tmp/cache/assets/ -rf
rm public/assets/locales/* -f
bundle exec rake tmp:create assets:precompile
```

!> bundle install或update之后需要重新**编译css/js**

<i class="fa fa-hashtag"></i>
没有热重载

部署代码后(如git pull)需要执行`restart`脚本重启puma服务器

<i class="fa fa-hashtag"></i>
log文件名不一样

由于服务器不一样，生产环境的log文件是`puma.stdout.log`和`puma.stderr.log`

## nginx所有二级域名的配置处

> /etc/nginx/sites-enabled
