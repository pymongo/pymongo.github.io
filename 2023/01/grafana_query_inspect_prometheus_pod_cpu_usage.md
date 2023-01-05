# [grafana query cpu usage](/2023/01/grafana_query_inspect_prometheus_pod_cpu_usage.md)

想要查 pod 的 cpu 使用率时序数据，K8s 已装 metrics-server, node-exporter, prometheus, grafana 等等

不会写 PromQL 可以抄一份别人的配置和查询

## grafana 导入别人的 dashboard

以我看的这边文章为例 <https://juejin.cn/post/7145097927067697159>

作者在 grafana dashboard marketplace 中的 id 是 3119

grafana 左侧菜单 dashboard->browse->import

粘贴 3119 的链接 <grafana.com/grafana/dashboards/3119>

**导入前记得选 data source 为自己的 prometheus**

![](import_dashboard_from_grafana_marketplace.png)

然后就能看到监控图表了

---

## pod cpu usage

我导入了 `Kubernetes Pods/Containers Resource Dashboard` 

图表顶部的有个 label 选中想看的 pod, 再选中 CPU usage 的 panel 的标题栏点 edit

最后点 query_inspector->query->refresh 然后就能得到请求 prometheus 的 json 格式去拿到 CPU 使用数据

![](grafana_panel_query_inspect.png)

grafana 的 query json 跟普罗米修斯 API 查询不太一样

```python
import requests
import urllib.parse
query='sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="host", pod="node-exporter-ms5ln", container="node-exporter"}[1m]))'
query=urllib.parse.urlencode({
    "query": query
})
url=f"http://prometheus:9090/api/v1/query?{query}"
rsp=requests.get(url)
print(rsp.status_code, rsp.text)
```

普罗米休斯的接口返回值为

> 200 {"status":"success","data":{"resultType":"vector","result":[{"metric":{"pod":"node-exporter-ms5ln"},"value":[1672832950.772,"0.036715530525449035"]}]}}

## rate function

普罗米休斯最简单的数据类型就是 Gauge 可以认为是普通数值，例如 pod 的 CPU request/limit 设置(request<=limit) 或者负载数据，histogram/summary 就是直方图例如统计接口的处理/响应时间(延迟)

例如接口响应延迟的 histogram_quantile p99 时间是 100ms 意思是 99% 的请求都是 100ms 内返回，1% 的请求次数响应时间大于 1%

container_cpu_usage_seconds_total 是一个 counter 类型(可通过 metrics browser 看数据类型)

操作系统 /proc/cpuinfo 使用率本身就是一个计数器，统计耗费 CPU 时间多少，如果短期内 CPU 时间增量迅速说明此时系统 CPU 使用率很高

因为 counter 类型就是一个单调递增的直线(例如接口请求次数)，只有单位增量的统计才有意义，例如哪个时间段接口请求并发量很大

`rate(container_cpu_usage_seconds_total{}[1m])` 的意思是 1 分钟内 counter 每秒增量的平均值，如果按时间范围去查询，这个 1 分钟有点像一个长度为 1 的滑动窗口

rate() 函数用于计算在指定时间范围内计数器每秒增加量的平均值

## 最终 cpu 使用率查询

首先 cpu 的使用率，分母应该是 pod 的 cpu limit 设置，单位是处理器核心数

kube_pod_container_resource_limits 是 gauge 类型按理来说是常量，不知道为何我的 pod 返回了两个值，可能是 pod 发生重启导致有了两个一样的数值，返回数组是 [2, 2]，所以我用 avg 聚合成一个值

> avg(kube_pod_container_resource_limits{resource="cpu", namespace="host", pod="redis"})

查询出的结果为 2 跟 kubectl describe pod 得到的结果一致

接下来查询下最近一分钟的 cpu 最大使用率，查询结果为 1.76，跟 pod 最近高负载的事实接近

> last_over_time( rate(container_cpu_usage_seconds_total{namespace="host", pod="redis"}[1m]) )

我一开始用 sum 结果发现得到的数字大于 2 很多，于是我改成了 max
