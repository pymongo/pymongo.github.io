# [docker19 buildkit](/2022/07/docker_buildkit_on_docker_19.md)

我认为 docker buildkit feature 最重要的作用就是 mount-type=cache 具体使用例子可以看 github 上搜 `docker buildkit syntax`

在我 archlinux 20 版本的 docker 中能用，但在 ubuntu 20.04 装的 docker 19 中提示 syntax error 要在 Dockerfile 第一行加上一个注释才能用

<https://stackoverflow.com/questions/55153089/error-response-from-daemon-dockerfile-parse-error-unknown-flag-mount?answertab=trending#tab-top>
