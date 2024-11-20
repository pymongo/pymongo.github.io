# [aws弹性IP](/2024/11/aws_elastic_ip.md)

币安一些代理商/中介可能要求 不允许修改白名单IP

当我发现EC2机器配置不够的时候，想换配置更好EC2但是不想换IP的话，可以用Elastic IP

EC2 > Elastic IP addresses > Allocate Elastic IP address

要先创建EC2 可以选不分配IPv4 创建好之后 弹性IP面板 associate IP to instance

~~好像可以用 transfer 功能把已有的 EC2 随机分配的IP 转换成固定的弹性IP~~
