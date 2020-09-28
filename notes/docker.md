# docker notes

## image和container的关系

container是容器，可以在docker desktop的App里看到容器列表，也可以用`docker container ls`去查看已安装的container

container类似虚拟机，一般只对外暴露一个接口, 5631:6379表示container内部的6379映射端口到localhost的5631端口

`docker container inspect 6a5c9a009dd5`可以显示container的详细信息

类似的，可以通过`docker container ls`的方式列出所有镜像，image的概率类似于apt-get的软件包，例如redis

