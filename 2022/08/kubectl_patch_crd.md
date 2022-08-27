# [K8s patch CRD](/2022/08/kubectl_patch_crd.md)

## set image 不用用于 CRD

> kubectl set image deployment/nginx container_name=$image

由于 K8s 的 CRD 不能使用 set image 更新镜像进行部署，我想更新 ray cluster 的镜像就只能 kubectl patch 了

## 获取 CRD 名称

> kubectl get crd

```
NAME                                         CREATED AT
alertmanagerconfigs.monitoring.coreos.com    2022-03-15T10:13:02Z
...
podmonitors.monitoring.coreos.com            2022-03-15T10:13:02Z
probes.monitoring.coreos.com                 2022-03-15T10:13:02Z
prometheusrules.monitoring.coreos.com        2022-03-15T10:13:02Z
proxyconfigs.networking.istio.io             2022-04-29T10:18:07Z
rayclusters.cluster.ray.io                   2022-06-11T01:28:47Z
...
```

```
$ kubectl describe crd rayclusters.cluster.ray.io | grep Singular -B5
  Group:       cluster.ray.io
  Names:
    Kind:       RayCluster
    List Kind:  RayClusterList
    Plural:     rayclusters
    Singular:   raycluster
--
Status:
  Accepted Names:
    Kind:       RayCluster
    List Kind:  RayClusterList
    Plural:     rayclusters
    Singular:   raycluster
```

ok 终于知道 rayclusters.cluster.ray.io 这个 CRD 提供了 raycluster

## kubectl explain

```
$ kubectl explain raycluster
KIND:     RayCluster
VERSION:  cluster.ray.io/v1
```

## patch CRD

kubectl get raycluster 找到要修改的目标 yaml 

由于 kubectl describe 返回的格式类似 yaml 但又不是，还是得 `get -o json` 看看字段层级嵌套

同事说可以用 patch 于是我看到这样的写法 <https://stackoverflow.com/a/36924484>

> kubectl patch deployment myapp-deployment -p '{"spec":{"template":{"spec":{"containers":[{"name":"myapp","image":"172.20.34.206:5000/myapp:img:3.0"}]}}}}'

我吐了写一个如此之长的 json 好容易出错，还是换种方法写

## 找 image 字段

```
$ kubectl get -o json raycluster cluster-b | jq .spec.podTypes[].name
"rayHeadType"
"rayWorkerType"

kubectl get -o json raycluster idp-raycluster-b-1563128371764129792 | jq .spec.podTypes[].podConfig.spec.containers[].image
"app:v1"
"app:v2"
```

## yq 生成 yaml

更合理是用 jq 或者 yq 这样的工具类似 json pointer 的方法去指定要修改的 json field

(jq 其实用的不是 json pointer)

注意 pacman/pip3 装的那个 yq 用的人较少，要用 mikefarah.gitbook.io 这个 golang 的 yq

但我感觉专注于 jq 就够了

```
$ yq --null-input '.spec.podTypes[0].podConfig.spec.containers[0].image="content"'
spec:
  podTypes:
    - podConfig:
        spec:
          containers:
            - image: content
```

```
[w@ww Downloads]$ jq -n ".spec.podTypes[0].podConfig.spec.containers[0].image = 123"
{
  "spec": {
    "podTypes": [
        {
        "podConfig": {
            "spec": {
                "containers": [
                    {
                        "image": 123
                    }
                ]
            }
        }
        }
    ]
  }
}
```

但问题来了，jq 也没法指定 header 和 worker 用不同镜像啊

## 失败的 patch

尝试 patch 刚开始 bash 多行字符串把 json 双引号弄没了，解决后遇到报错

> Error from server (UnsupportedMediaType): the body of the request was in an unknown format - accepted media types include: application/json-patch+json, application/merge-patch+json, application/apply-patch+yaml

原来是没有加 --type=merge 参数，加上后就好了

```bash
patch_json=$(python3 -c 'print("""
{
    "spec": {
        "podTypes": [
            {
                "name": "rayHeadType",
                "podConfig": {
                    "spec": {
                        "containers": [
                            {
                                "image": "$repo/$base"
                            }
                        ]
                    }
                }
            },
            {
                "name": "rayWorkerType",
                "podConfig": {
                    "spec": {
                        "containers": [
                            {
                                "image": "$repo/$base"
                            }
                        ]
                    }
                }
            }
        ]
    }
}""")')
ssh server "kubectl -n $namespace patch raycluster idp-raycluster-b-$team_id --patch '$patch_json' --type merge"

The RayCluster "idp-raycluster-b-1563300506009985024" is invalid: 
* spec.podTypes.podConfig.spec.containers.name: Required value
* spec.podTypes[0].podConfig.apiVersion: Required value: must not be empty
* spec.podTypes[0].podConfig.kind: Required value: must not be empty
* spec.podTypes[1].podConfig.apiVersion: Required value: must not be empty
* spec.podTypes[1].podConfig.kind: Required value: must not be empty
```

好在 K8s 报错提示信息够多足以修复

## patch 的 json 模板

```bash
patch_json_template='
{
    "spec": {
        "podTypes": [
            {
                "name": "rayHeadType",
                "podConfig": {
                    "kind": "Pod",
                    "apiVersion": "v1",
                    "spec": {
                        "containers": [
                            {
                                "name": "ray-node",
                                "image": "%s"
                            }
                        ]
                    }
                }
            },
            {
                "name": "rayWorkerType",
                "podConfig": {
                    "kind": "Pod",
                    "apiVersion": "v1",
                    "spec": {
                        "containers": [
                            {
                                "name": "ray-node",
                                "image": "%s"
                            }
                        ]
                    }
                }
            }
        ]
    }
}'
patch_json=$(printf "$patch_json_template" $repo/$header_img $repo/$worker_img)
ssh server "kubectl -n $namespace patch app --patch '$patch_json' --type merge"

raycluster.cluster.ray.io/app patched
```

总算成功修改，但该 CRD 对应的 【pod 没重启说明配置报错】，describe raycluster 看看原来是报错了

一直卡在 AutoscalingExceptionRecovery 状态

```
  Error  Logging  18m   kopf  Handler 'create_or_update_cluster' failed with an exception. Will retry.
Traceback (most recent call last):
  File "/home/ray/anaconda3/lib/python3.9/site-packages/kopf/_core/actions/execution.py", line 279, in execute_handler_once
    result = await invoke_handler(
  File "/home/ray/anaconda3/lib/python3.9/site-packages/kopf/_core/actions/execution.py", line 374, in invoke_handler
    result = await invocation.invoke(
  File "/home/ray/anaconda3/lib/python3.9/site-packages/kopf/_core/actions/invocation.py...packages/ray/ray_operator/operator.py", line 282, in _create_or_update_cluster
    cluster_config = operator_utils.cr_to_config(cluster_cr_body)
  File "/home/ray/anaconda3/lib/python3.9/site-packages/ray/ray_operator/operator_utils.py", line 111, in cr_to_config
    config["available_node_types"] = get_node_types(
  File "/home/ray/anaconda3/lib/python3.9/site-packages/ray/ray_operator/operator_utils.py", line 133, in get_node_types
    metadata = node_type["node_config"]["metadata"]
KeyError: 'metadata'
```

原来是 --type=merge 把原来 json 的其他字段都干没了... 并不是 **局部更新**

## patch 局部更新

```
ssh server "kubectl -n $namespace patch app --type=json --patch=\
'[
    {"op": "replace", "path": "/spec/podTypes/0/podConfig/spec/containers/0/image", "value": "$repo/$base"},
    {"op": "replace", "path": "/spec/podTypes/1/podConfig/spec/containers/0/image", "value": "$repo/$base"}
]' "
```

显然这里 path 的语法格式是 json pointer 终于看到 patch 生效而且 CRD 对应的 pod 也重启了

## 总结

<https://twitter.com/ospopen/status/1563369621318938625>

```
CRD 不支持 set image
于是 patch json 报错 unknown format

加了个 --type=merge 参数能成功，
以为是局部更新配置结果是全量更新，没了其他字段各种报错

同事说 kubectl patch --type=json -p '[{"op":"replace","path":"/spec/image","value":"a"}]'
path 是 json pointer 语法，就能更新一个字段
```
