# Graphql笔记

Graphql和protobuf是我入职现在公司后接触到的两个技术

## graphql client

```
class HttpClient:
    GRAPHQL_SCHEMA = {
        'sign_up': '''
            mutation($email: String!, $password: String!) {
                signUp(email: $email, password: $password) {
                    email
                }
            }
        ''',
    }

    def __init__(self, url: str):
        self.conn = http.client.HTTPConnection(url, timeout=8)

    def send_req(self, query: str, variables: Optional[Dict[str, Any]] = None):
        # 不确定request body是否需要json.dumps
        body = json.dumps({
            "query": self.GRAPHQL_SCHEMA[query],
            "variables": None if variables is None else variables
        })
        self.conn.request("POST", "/api", body, headers={
            "Content-Type": "application/json"
        })
        resp = self.conn.getresponse()
        assert resp.status == 200
        resp = json.loads(resp.read().decode('utf-8')) # resp is a Dict[str, Any]
        print(json.dumps(resp, indent=4))
        return resp
```

## dataloader(N+1查询)和一次请求多个查询

graphql和Restful的最大区别在于，可以一次请求无数个query/mutation/subscription

例如一次请求注册两个个账号的示例

```
mutation($email: String!, $password: String!) {
    signUp(email: $email, password: $password) {
        email
    }
    signUp(email: $email, password: $password) {
        email
    }
}
```

如果并发量大或者有请求恶意重复访问相同的接口1千多次，就可能会处理一次请求需要查上千次数据库

github.com/graphql/dataloader 就是为了解决这个问题

## look_ahead 只处理需要返回的字段

注意look_ahead只针对async-graphql的SimpleObject resolver

假设有个接口有a,b,c三个字段，分别需要三个不同的SQL得到查询结果

graphql默认下即便只要一个字段，也会把三个字段的值计算出来再只取字段a

async-graphql::Context的look_ahead API可以检测查询了哪几个字段

如果只需要a，则只执行计算a的SQL，b和c赋一个默认值即可
