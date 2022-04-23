# [nginx 403](/2022/04/nginx_403.md)

nginx 403 很可能的原因是 【nginx 系统用户不存在】或者 nginx 用户没权限读静态文件

没想到 manjaro/arch 的 nginux 包居然没有自动创建 nginx 用户，所以要改下配置

/etc/nginx/nginx.conf

```
user root;
worker_processes  1;
#pid        logs/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include /etc/nginx/conf.d/*.conf;
```

加上 `user root;` 一行以及 http 配置中加上 `include /etc/nginx/conf.d/*.conf;`

另外 nginx 502 错误要么是 proxy_pass 的应用没有启动，要么是应用发生 panic
