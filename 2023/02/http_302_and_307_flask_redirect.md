# [HTTP 302/307 flask](/2023/02/http_302_and_307_flask_redirect.md)

最近有个接口要从服务 a 挪到服务 b， 由于灰度发布考虑两边都有相同的接口都会共存一段时间

所以我思考能不能在 a 中直接类似 rails 的 redirect 转发请求到 b 接口

```python
@app.route("/api", methods=["POST"])
def api_handler():
    # 注: service_b 会被网关 rewrite 没掉
    return flask.redirect(f'http://localhost:7777/service_b/api')
```

结果测试发现 `(failed)net::ERR_CONNECTION_REFUSED`

才想起这是重定向而不是网关转发的 proxy_pass 等于让用户浏览器请求用户自身的 localhost 当然网络不通，还有跨域问题

## mixed-content blocked

将 localhost 改成服务的公网域名后，通过网关日志看总算转发成功了，但是状态码 302 mixed

问前端，前端说 302 都是浏览器自动处理的，前端也无法干预，并不是前端的 axios 之类的请求拦截器拦截了请求

[查资料](https://stackoverflow.com/a/33507729)发现是服务端有 HTTPS 而我用 HTTP 的原因

## 302 POST 变 GET

改 https 之后终于请求通了，可是服务 b 报错 305

原来 flask 默认用 302 转发标准，所有请求方法转发后都会变成 GET 于是我改用 307 就没问题了

302/307 是临时重定向，301/308 是永久重定向，永久重定向就是随后所有请求都在重定向网址

问了下 chatGPT 说 302 和 307 的区别除了请求方法不同，302 可以缓存但 307 没缓存

---

最后我发现请求的 query_string 丢了，也不是丢了，只是要显式写到 redirect 的链接里面

```python
query_string = request.query_string.decode()
return flask.redirect(f'https://{DOMAIN}/service_b/api?{query_string}', code=307)
```
