# docker notes

## image和container的关系

container is an instance of image, one container can only have one image.

## 一个container=一个进程=一个service=一个端口

docker的理念是尽可能解耦/切分最小单元，docker的一个container中只跑一个"进程"，也只有一个和Host OS相通的端口，

每个container中只会跑一个service，例如redis要用一个container，MySQL要用另一个container

`-p 5631:6379`表示container内部的6379端口(redis-server)映射到localhost的5631端口，访问本机的5631端口等同于访问redis container的6379redis端口

## 启动一个Ubuntu container

错误示例: docker run -d --name ubuntu --restart always -p 20000:10000 ubuntu，-d参数表示后台运行

[为什么ubuntu安装后会无限关机重启循环?](https://stackoverflow.com/questions/30209776/docker-container-will-automatically-stop-after-docker-run-d)

The centos/ubuntu dockerfile has a default command bash.

That means, when run in background (-d), the shell exits immediately.

正确命令: `docker run -d -t --name ubuntu -p 20000:10000 ubuntu`

ubuntu container创建后，可以通过`docker ps -a`或`docker container ls -a`查看所有container的状态，检查是否运行正常

`docker container inspect ubuntu`可以显示ubuntu container的详细信息

## 连接ubuntu的shell

`docker exec -it ubuntu /bin/bash`，-i: 交互式操作，-t: 终端

查看ubuntu container的stdout/stderr: `docker logs ubuntu`

docker安装的精简版的ubuntu，并没有lsb_release命令去查看ubuntu版本，不过这些版本信息其实可以通过cat某些文本文件去查看

`cat /proc/version /etc/issue /etc/lsb-release`

然后安装一些必备软件:

`apt update && apt install -y curl git gcc g++ vim`

既然必备的软件都安装好了，接下来应该保存配置好的ubuntu系统image

## 将container的状态和数据制作成image快照方便回滚和分享

将当前的ubuntu快照制作成image`docker export 40916c380bae > my_ubuntu.tar`名字随便起，叫my_ubuntu.tgz也行

将我制作的ubuntu镜像导入到本地的docker image list中`docker import ubuntu.tar`

刚导入的镜像repo和tag都为none，重命名一下`docker image tag 8941fd95c1c4 my_ubuntu/server:latest`

其实解压ubuntu.tar后发现就是完整的linxu系统文件，通过export镜像可以分享镜像、image版本管理等

## docker容器间互连

TODO

### docker network命令

TODO

## Dockerfile

TODO

## Kubernetes

谐音k8s，k和s中间有8个字母。k8s是docker集群的监控编排管理软件，

提供负载均衡、自动扩容缩容、自我修复等功能，运维再也不需要因为某个container挂了或硬盘满了需要扩容而半夜爬起来
