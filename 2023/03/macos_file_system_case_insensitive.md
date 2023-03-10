# [mac 文件系统不区分大小写](/2023/03/macos_file_system_case_insensitive.md)

同事重构了前端项目一些文件名，代码提交后，在我 Linux 机器上不能编译了

原来是 mac/windows 文件系统不区分大小写，所以例如 userId.js 重构为 UserId.js 默认下 git 不会感知到变化

解决办法是上述操作系统 git 全局打开 case sensitive 或者 macos 创建硬盘分区的时候勾选区分大小写
