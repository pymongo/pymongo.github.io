# [aws T系列积分机制](/2024/04/aws_t2_nano_cpu_credit.md)

<https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/unlimited-mode-examples.html>

aws t2.nano EC2 instance 有一种叫 CPU 积分的机制

CPU 闲置 24 小时可以获得积分，CPU 自旋锁打满快速消耗积分，积分扣完了扣网费

对于 t2.nano 部署的交易程序不要用自旋，要么就用 C系列 独占 CPU
