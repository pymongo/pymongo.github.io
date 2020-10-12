# 计算机网络

## OSI model

Open Systems Interconnection model 7 layer:

1. Physical
2. Data-Link(contains MAC layer): Wi-Fi, Ethernet
3. Network: route
4: Transport: UDP(User Datagram Protocol), TCP(Transmission Control Protocol)
5. Session(full-duplex/half-duplex/simplex): RPC 
6. Presentation: ASCII-encoded
7. Application: HTTP

## TCP三次握手和四次握手

建立连接3次握手，终止连接4次握手

Physics

===

## 几个项目用不上但是挺有用的js API

btoa: string->base64

decodeURIComponent("%2c") = ",":

Fb的Graph API由于全是GET请求，需要用到大量的percent encode, 例如%28等于左括号

## 沙拉查词插件

两点让我眼前一亮：事无巨细的配置项，而且配置项能同步到谷歌账号上换电脑只要登录谷歌账号就能同步配置项(除了单词本要手动导出导入)

普通查词设置上，只勾选Alt按键查词的选项，然后就可以按住Alt键双击某个单词完成「单个单词查词」或按住Alt键选中句子完成「段落/句子翻译」

也可以长按cmd/win键弹出独立的带自动补全的查词/词典
