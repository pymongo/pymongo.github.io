# [goproxy](/2022/08/goproxy.md)

最近给 CI 机器测试 license header 检查工具 license-eye

需要通过 go install 安装，设置了 http_proxy 依然被墙，开了 OpenVPN 翻墙勉强能下载

后来看网上大伙说用七牛云的 goproxy.cn 设置成全局环境变量 GOPROXY 就好了

感慨 go 语言官网被墙，连 go install 任何东西都可能走一遍 google 域名导致也被墙
