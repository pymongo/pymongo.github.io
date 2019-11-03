# 初始化base-api遇到的各种报错

## bundle版本问题

无法bundle install，bundle版本出问题了

不推荐的解决方案：

> gem update --system AND gem update bundle

Gemfile.lock最后一行提示了项目的bundle版本

> BUNDLED WITH 1.16.2

最佳解决方案是: 

> gem install bundle -v1.6.2

虽然这样做会有多个bundle的版本，但是切到base-api的目录时就是1.你6.2了

## passgn 安装报错

这是个密码相关的包，bundle安装的时候报错了，需要用gem install passgn -v 1.0.2

## database.xml.example

进入到config目录，发现所有yml配置文件都带.example后缀

虽然我们的代码仓库是付费的私密仓库，大师说github上面好多黑客用脚本扫描git仓库

例如发现我们的项目文件结构是rails就会扫描config目录下的database.yml获取数据库密码

所以git仓库上的database.yml一定不能有密码信息，而且要改名为.example后缀防止脚本扫描也方便版本管理

## log4r报错

[大师博客上的解决方案](http://siwei.me/blog/posts/log4r)

## puma： No such file

由于生产环境在/opt里有个puma的设置，而本地环境没有

所以把config/puma.rb删掉就好了

## database.yml

1. 修改密码
2. 修改数据库的库名

