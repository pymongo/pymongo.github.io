# [docker rm by glob](/2022/04/docker_image_rm_by_glob.md)

之前为了 kubectl set image 部署在 CI 中每次都会打一个当前时间的 TAG

每个月能产生 200 G 的镜像，所以我用以下命令一次删除 3 月分 CI 中构建的镜像

docker images 的 -q 参数可以只列出 image 的 hash

docker rmi $(docker images "idp-note:22-03*" -q)
