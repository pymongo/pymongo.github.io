# [K8s entrypoint](/2022/06/k8s_entrypoint.md)

学习和使用 dockerfile 的时候我总是分不清 CMD 和 entrypoint 两个相似的概念

最近在一个不同的 K8s 版本机器上做部署的发现有个镜像写的是 CMD app 结果用不了

一运行 K8s 就识别不了 entrypoint 似的直接 complete 然后 crash

写 CMD 的镜像可以用 `docker run -it img bash` 不用镜像的原 entrypoint 去跑而用 bash 进去看看

-i 参数无需过多解释就是 交互式的意思，例如 python shell

-t 参数是 tty 的意思，也可补习下 K8s deploy 的 tty/stdin 选项配置

如果镜像 Dockerfile 写的是 entrypoint 则只能用 `docker run -it --entrypoint bash img`

---

考虑 Dockerfile 写 ENTRYPOINT 兼容性更好，建议只用 ENTRYPOINT 即可
