# [节点亲和](/2023/06/kubernetes_node_affinity.md)

最近遇到一个 pod 启动失败，报错原因是 NodeAffinity

> what is Pod Predicate NodeAffinity failed means in k8s

```
In Kubernetes, Pod Predicate is a mechanism that allows you to filter out nodes based on certain criteria before scheduling a pod. NodeAffinity is one of the types of predicates that can be used to match pods to specific nodes based on labels and other criteria.

When a pod fails due to a Pod Predicate NodeAffinity issue, it means that the pod's node affinity rules could not be satisfied and as a result, the pod could not be scheduled to any node in the cluster. This happens when there are no nodes in the cluster that meet the specified criteria set by the node affinity rule.

Some common reasons why a pod may fail due to node affinity include:

Incorrect label selector: If the label selector provided in the node affinity rule does not match any nodes in the cluster, then the pod will fail to schedule.
Insufficient resources: If all the nodes that match the label selector do not have sufficient resources (such as CPU or memory) to run the pod, then the pod will fail to schedule.
Conflicting rules: If there are conflicting node affinity rules where two or more rules cannot be satisfied at the same time, then the pod will fail to schedule.
To troubleshoot Pod Predicate NodeAffinity failures, you can check the logs and events for the pod and the affected nodes. You may need to adjust the node affinity rules to match the available nodes or increase the resources available on the nodes to satisfy the pod's requirements.
```

总的来说要么是资源不足启动不了，要么就排查下 pod 的 node label selector 和每个节点的 label 是否匹配上
