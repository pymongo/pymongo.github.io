# [python ray](/2022/05/python_ray.md)

ray 可以通过分布式加速 python 代码执行，也可以基于 ray 开发分布式应用(只用 ray 的调度部分)

## task/actor

- task  适用于无状态单次执行的 Future (@ray.remote 注解的函数)
- actor 适用于有状态可能多次执行的 Future (类)

## ray cluster

首先有一个 head 的概念
