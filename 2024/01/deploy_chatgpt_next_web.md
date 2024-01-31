# [部署gpt nextweb](/2024/01/deploy_chatgpt_next_web.md)

之前一直在 use.aihomego.com 用gpt4月会员，今天到期了，一直不爽这种多个人共用多个gpt4账号池，经常会被分配到被限速很慢的账号

于是我还是考虑买一个gpt api key独享账号，顺便对比下比20刀一个月的gpt plus价格哪个更划算

```
docker run --name gpt --net=host --restart=always \
   -e BASE_URL=https://one-api.xiaobaiteam.com \
   -e CUSTOM_MODELS=-all,+gpt-4-1106-preview \
   -e OPENAI_API_KEY=foo \
   -e PROXY_URL=socks5://127.0.0.1:10808 \
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
Checking repo... OK
The main bucket was added successfully.

scoop bucket add versions
# from versions bucket
scoop install nodejs18
scoop install yarn
yarn config set registry https://registry.npmmirror.com
yarn install
```

.env.local

```
BASE_URL=https://one-api.xiaobaiteam.com
CUSTOM_MODELS=-all,+gpt-4-1106-preview
OPENAI_API_KEY=foo
PROXY_URL=socks5://127.0.0.1:10808
```

```
Exit code: 1
Command: node scripts/postinstall.mjs
Arguments:
Directory: C:\Users\w\ChatGPT-Next-Web\node_modules\@vercel\speed-insights
Output:
The system cannot find the path specified.

Error: EPERM: operation not permitted, mkdir 'C:\Users\�����Ƽ�\scoop\
```

> yarn config set script-shell powershell

windows scoop 安装的 npm 有权限问题不能 npm install -g 我改回 nodejs 官方安装包

```
npm ERR! command failed
npm ERR! command powershell -c :; (node ./preinstall.js > /dev/null 2>&1 || true)
```

> ChatGPT-Next-Web/node_modules/.bin/cross-env: 12: node: not found

npm config set script-shell bash
npm config delete script-shell
npm config get script-shell

艰难啊，花了一个小时才把wsl systemd docker 的 nextweb 部署换成 windows 源码编译部署

总结两大踩坑是，不要用scoop安装要用nodejs官网msi安装包安装 和 不要`npm config set script-shell bash`这样会调用wsl linux的bash无法找到windows的node可执行文件

精简下windows源码编译nextweb过程

```
node-v20.11.0-x64.msi
npm config set registry https://registry.npmmirror.com
npm install -g yarn
yarn config set registry https://registry.npmmirror.com
yarn install
yarn build 
yarn start
```

## 必须关闭Auto Generate Title否则扣两次钱

跟官方 gpt web的行为一样，每次问答后，还会将当前会话的所有内容发给gpt动态生成/更新会话的标题，这样导致提问一次会扣费两次，一定要关掉这个没啥用的配置省点钱，目前我才用了两天就花了 1.3$

但我发现前端缓存没了或者wsl2 docker崩溃恢复出厂设置了，Auto Generate Title设置就变成默认了，所以我还是用环境变量 CUSTOM_MODELS 指定只用 gpt4 模型白名单，这样nextweb看到没有便宜的gpt 3.5就不会在对话结束后发请求生成标题了减少每次对话额外一次3.5的扣费
