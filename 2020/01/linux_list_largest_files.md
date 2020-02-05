# [运维 - 服务器硬盘满了——列出最大文件](/2020/01/linux_list_largest_files.md)

话说测试服务器的硬盘空间又满了，没法git pull、bash自动补全、Web服务器没法上传文件等等

> sudo du -a / | sort -n -r | head -n 20

于是查出上述命名，列出硬盘里最大的20个文件/文件夹

排第一的是`/opt/app/rails_api/releases/xxx/nohup.out`

排第二的是`xxx/websocket-server/log/puma.stdout.log`

排第三的是`/var`，数据库就存在这里，此时想起v2ex上某帖把/var删了...

---

服务器在跑着呢，总不能把log文件删掉吧，于是有这么一招

`echo '' > xxx/websocket-server/log/puma.stdout.log`
