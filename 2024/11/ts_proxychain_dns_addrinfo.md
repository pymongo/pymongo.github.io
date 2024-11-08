# [ts不代理DNS](/2024/11/ts_proxychain_dns_addrinfo.md)

nodejs 本地开发设置proxy就是很麻烦 chatgpt-next-web 的作者推荐用 proxychains

我尝试 solana js 用 HttpsProxyAgent 替换请求 agent 和 fetch 方法

首先这样改会一堆类型报错 要么 `// @ts-ignore` 要么 `fetch: fetchWithProxy as any`

其次 solana js 2.0 版本 API 改了，构造函数传入 http agent 的位置变了，侵入式代理的代码很不人体工学也不好维护

于是我尝试 `proxychains npx ts-node main.ts`

运行node就报错 `getaddrinfo.c:90: uv__getaddrinfo_translate_error`

问了 API 才知道，node 用 proxychains 由于 C 代码库 uvloop 各种问题要 /etc/proxychains.conf 配置中禁用 DNS 代理请求

> #proxy_dns
