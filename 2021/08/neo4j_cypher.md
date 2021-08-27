# [neo4j cypher](/2021/08/neo4j_cypher.md)

## neo4j 工具生态

### neo4j server

aur 上面那个 neo4j 运行报错，我从 neo4j 官网下载 server 可执行文件

运行前要用 archlinux-java 切换成 jdk-11

### neo4j desktop

我暂时没搞懂有什么用

## auth

默认用户名密码都是 neo4j，第一次登陆时需要强制需要修改 neo4j 帐号的密码

### user 信息常用查询

跟 SQL 一样 cypher GQL 的关键词也是不区分大小写的

- show users
- show current user

---

## MATCH

MATCH 类似 SQL 的 SELECT

---

```
create vertex tree_node(primary key id int32, val int32);
create edge tree_node_edge(created_at date nullable);

create
    (parent:tree_node {id: 0, val: 1}),
    (left_child:tree_node {id: 1, val: 2}),
    (right_child:tree_node {id: 2, val: 3});
match (parent:tree_node), (left_child:tree_node)
create (parent)-[left_edge:tree_node_edge]->(left_child) return left_edge;
match (parent:tree_node), (right_child:tree_node)
create (parent)-[right_edge:tree_node_edge]->(right_child);

match (n:tree_node) return n;
```

## variable similar to AS in SQL

create (b:p{id:4}) return b;

b 只是个作用域在当前 cypher 语句的变量名而已，后续查询还是要用 id 指定点

语句 1 中用到的变量名字 a 会在语句 2 中不可用，语句 2 应该用 where a.id=1 去指定 语句 1 创建的点
