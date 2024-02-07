# [部署gpt nextweb](/2024/01/deploy_chatgpt_next_web.md)

之前一直在 use.aihomego.com 用gpt4月会员，今天到期了，一直不爽这种多个人共用多个gpt4账号池，经常会被分配到被限速很慢的账号

于是我还是考虑买一个gpt api key独享账号，顺便对比下比20刀一个月的gpt plus价格哪个更划算

```
docker run -d --name gpt --net=host --restart=always \
   -e BASE_URL=https://one-api.xiaobaiteam.com \
   -e CUSTOM_MODELS=-all,+gpt-4-0125-preview \
   -e OPENAI_API_KEY=sk- \
   -e PROXY_URL=socks5://172.25.240.1:10808 \
   -e PORT=4000 \
   yidadaa/chatgpt-next-web
```

(小白 AI 服务器在东京国内偶尔无法直连还是得代理)

In PowerShell, you can use the backtick character (`) as the line continuation char

用nginx反向代理略有很多不同和配置，我就暂不考虑

在管理员权限的 windows powershell(admin) 

> New-NetFirewallRule -DisplayName 'Docker port 3000' -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow

这样让本来只能在 localhost:3000 访问 gpt web 暴露在以太网/内网上

最后是去掉防火墙规则的代码

> Remove-NetFirewallRule -DisplayName 'Docker port 3000'

## 不建议wsl docker部署

wsl的network=mirrored老有bug，发生oom之后或者其他未知原因，从windows curl 3000 端口就卡住了网页就fail to fetch，不可靠，要重启才能恢复

```
PS C:\Users\w> scoop install ruby
Couldn't find manifest for 'ruby'.
PS C:\Users\w> scoop bucket list
WARN  No bucket found. Please run 'scoop bucket add main' to add the default 'main' bucket.
PS C:\Users\w> scoop bucket add main
The main bucket was added successfully.

scoop bucket add versions
scoop install nodejs18
scoop install yarn
yarn config set registry https://registry.npmmirror.com
```

.env.local

```
BASE_URL=https://one-api.xiaobaiteam.com
CUSTOM_MODELS=-all,+gpt-4-0125-preview
OPENAI_API_KEY=sk-foo
PROXY_URL=socks5://127.0.0.1:10808
```

```
Exit code: 1
Directory: C:\Users\w\ChatGPT-Next-Web\node_modules\@vercel\speed-insights
Output:
The system cannot find the path specified.

Error: EPERM: operation not permitted, mkdir
```

> yarn config set script-shell powershell

windows scoop 安装的 npm 有权限问题不能 npm install -g 我改回 nodejs 官方安装包

> npm ERR! command powershell -c :; (node ./preinstall.js > /dev/null 2>&1 || true)

> ChatGPT-Next-Web/node_modules/.bin/cross-env: 12: node: not found

npm config set script-shell bash
npm config delete script-shell
npm config get script-shell

艰难啊，花了一个小时才把wsl systemd docker 的 nextweb 部署换成 windows 源码编译部署

总结两大踩坑是，不要用scoop安装要用nodejs官网msi安装包安装 和 不要`npm config set script-shell bash`这样会调用wsl linux的bash无法找到windows的node可执行文件

### 精简下windows源码编译nextweb过程

```
node-v20.11.0-x64.msi
npm config set registry https://registry.npmmirror.com
npm install -g yarn
yarn config set registry https://registry.npmmirror.com
yarn install
yarn build 
yarn start
```

### 防火墙允许node绑定0.0.0.0

`Get-Command node` 获取下 nodejs 绝对路径，官方安装包会安装到  C:\Program Files\nodejs\node.exe

如果 nodejs bind 0.0.0.0 仍然无法从其他设备访问，需要去 `Control Panel\All Control Panel Items\Windows Defender Firewall` Allow an app..

### windows proxychains

由于 PROXY_URL 配置项是docker部署only，windows上还是得需要个前置代理命令工具，例如经典的 proxychains

> scoop install proxychains

配置文件在 HOME 目录 scoop\apps\proxychains\current\proxychains.conf

只需要改最后的 ProxyList

```
[PID13180] [I] 2024/02/06 22:49:45 Mswsock.dll (FP)ConnectEx(916 127.0.0.1:63139 16) DIRECT
Assertion failed: uv__has_active_reqs((loop)), file c:\ws\deps\uv\src\win\tcp.c, line 1200
error Command failed with exit code 3221226505
```

windows proxychain curl 谷歌没问题偏偏 yarn start 一请求就报错，查了下还是一个nodejs libuv的C源码报错位置

作者在issue的评论说 `nodejs 没有比较好的 proxy 方案，我自己曾尝试过多种方案，都不太行，等 api 地址替换吧`

由于 wsl `networkingMode=mirrored` 对 nodejs 应用资源加载有 bug 所以我目前解决方案是 wsl linux 的 `apt install docker.io` 版本部署个端口 4000 的容器可配代理，然后windows上3000端口yarn start也部署一个 双份容灾

不过去掉 mirror 网络后懒得改我代理设置，用nginx将windows上两个代理服务器反向代理到linux的localhost

```
http {
    server {
        listen 10809;

        location / {
            proxy_pass http://172.25.240.1:10809;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}

stream {
    server {
        listen 10808;
        proxy_pass 172.25.240.1:10808;
        proxy_connect_timeout 1s;
    }
}
```

### nginx 部署

流失输出的问题参考 README 的配置

subpath/prefix 问题 https://github.com/ChatGPTNextWeb/ChatGPT-Next-Web/issues/693#issuecomment-1502658357

## 必须关闭Auto Generate Title否则扣两次钱

跟官方 gpt web的行为一样，每次问答后，还会将当前会话的所有内容发给gpt动态生成/更新会话的标题，这样导致提问一次会扣费两次，一定要关掉这个没啥用的配置省点钱，目前我才用了两天就花了 1.3$

但我发现前端缓存没了或者wsl2 docker崩溃恢复出厂设置了，Auto Generate Title设置就变成默认了，所以我还是用环境变量 CUSTOM_MODELS 指定只用 gpt4 模型白名单，这样nextweb看到没有便宜的gpt 3.5就不会在对话结束后发请求生成标题了减少每次对话额外一次3.5的扣费
