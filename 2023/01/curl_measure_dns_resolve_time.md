# [curl measure DNS latency](/2023/01/curl_measure_dns_resolve_time.md)

最近排查业务系统 DNS 解析很慢的问题，应用 K8s service 在 pod 启动前的 2-3 秒就自动创建好了

但是 pod 进入 running 状态之后过了 2-7s 其他 pod 才能网络请求到这个 pod 一直是 DNS name not resolve

<https://yuerblog.cc/2019/09/02/k8s-%E4%BC%98%E5%8C%96dns%E8%A7%A3%E6%9E%90%E6%97%B6%E9%97%B4/>

看到这篇文章说用 curl 测量 DNS 花费时间

curl 的 -w 参数可以传入一个耗时输出格式的文件来追踪记录请求耗时，具体格式抄下面答案就好

<https://stackoverflow.com/questions/18215389/how-do-i-measure-request-and-response-times-at-once-using-curl>

```
# curl -w "@format" http://pod-svc-name.namespace.svc.cluster.local:9008/health_check
     time_namelookup:  0.004651s
        time_connect:  0.004996s
     time_appconnect:  0.000000s
    time_pretransfer:  0.005113s
       time_redirect:  0.000000s
  time_starttransfer:  0.005373s
                     ----------
          time_total:  0.005402s
# curl -w "@format" http://10.103.0.246:9008/health_check
     time_namelookup:  0.000059s
        time_connect:  0.000313s
     time_appconnect:  0.000000s
    time_pretransfer:  0.000394s
       time_redirect:  0.000000s
  time_starttransfer:  0.000797s
                     ----------
          time_total:  0.000829s
```

用 ip 请求接口耗时只有 0.8ms 而走 svc 在 DNS 解析阶段就花了 4ms
