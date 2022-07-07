# [docker --progress=plain](/2022/07/docker_build_progress_plain.md)

自从启用 buildkit 之后 docker build 的进度条就变成固定高度滚动更新的内容

```
cat /etc/docker/daemon.json
{
    "features": { "buildkit": true }
}
```

导致运行到 STEP 6 的时候看不到 STEP 5 的 stdout，没开 buildkit 的时候 dockerfile 代码会打成白色而 stdout/stderr 打成红色

今天才发现 docker build 加上 **--progress=plain** 参数可以保留所有 STEP 的所有输出
