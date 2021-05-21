# [Nvidia CUDA](/2021/05/nvidia_cuda.md)

只要nvidia驱动正常，pacman -S cuda即可装上CUDA的SDK

可能源码编译CUDA才要linux-headers这个包

为了测试CUDA SDK是否正常工作，我还装了cuda-tools包含11.3版cuda的samples

编译运行所有samples都显示正常，但是运行Nvidia官网教程文章`Even easier introduction cuda`时就运行时报错segfault

我猜测是官网文章的cuda版本过旧跟我最新版cuda sdk不兼容

同样是一维向量的加法，我打开了运行正常的VectorAdd例子源码

结果源码200+行，光Makefile都400多行

一个最简单的例子难以看懂的400多行Makefile把我劝退了(买显卡时还想着日后能cuda深度学习所以买的N卡没买RX550)

¶ Reference
- <https://developer.nvidia.com/blog/even-easier-introduction-cuda/>
- <https://xcat-docs.readthedocs.io/en/stable/advanced/gpu/nvidia/verify_cuda_install.html>
