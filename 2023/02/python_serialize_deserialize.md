# [Python (反)序列化](/2023/02/python_serialize_deserialize.md)

pickle: bytes <-> object

如果是通用的传输格式 json/yaml/protobuf 呢，想把一个 json 序列化成"强类型"的 class/object 而不是一个 dict

## dataclass

```python
import dataclasses
import json
@dataclasses.dataclass
class User: id: int
user: User = json.loads(b'{"id":1}', object_hook=lambda x: User(**x))
print(user)
print(json.dumps(dataclasses.asdict(user)))
# User(id=1)
# {"id": 1}
```

dataclass 对于像 namedtuple 一样简单的单层的 json 反序列化和序列化达到预期效果

**但是不能用于多层嵌套的 json**

## namedtuple/TypedDict?

pycharm/pylance 都无法识别这两动态创建的类，没有自动补全等提示，对开发极不友好

## marshmallow

marshmallow 是个第三方库序列化框架，可以作为致命 ORM 库 SQLAlchemy 的序列化反序列化格式

```python
from marshmallow import Schema, fields
import json

class CamelCaseSchema(Schema):
    def on_bind_field(self, field_name, field_obj):
        def camelcase(s):
            parts = iter(s.split("_"))
            return next(parts) + "".join(i.title() for i in parts)
        field_obj.data_key = camelcase(field_obj.data_key or field_name)
class Job(Schema):
    id = fields.Integer()
class User(CamelCaseSchema):
    user_jobs = fields.List(fields.Nested(Job()))

loaded = User().load(json.loads(b'{"userJobs":[{"id":1}]}'))
print(type(loaded), loaded)
# <class 'dict'> {'user_jobs': [{'id': 1}]}
dumped = User().dump(loaded)
print(dumped)
# {'userJobs': [{'id': 1}]}
```

默认是 serde(deny_unknown_fields)

如果想忽略多余字段，则需要加一个**内部类**，例如

```python
@dataclass
class Graph:
    nodes: List[Node]
    edges: List[Edge]
    class Meta:
        unknown = marshmallow.EXCLUDE
```

虽然支持 serde(rename_all) 但输入是 dict 反序列化的结果还是dict 只能作为一个 Validation 检查 json 有没有缺字段

## marshmallow_dataclass

```python
import json
from marshmallow_dataclass import dataclass
from typing import List
@dataclass
class Job:
    id: int
@dataclass
class User:
    userJobs: List[Job]
    class Meta: unknown = "exclude"

loaded: User = User.Schema().load(json.loads('{"userJobs":[{"id":1}], "unknownField":1}'))
print(type(User), loaded)
print(User.Schema().dump(loaded))
# <class 'type'> User(userJobs=[Job(id=1)])
# {'userJobs': [{'id': 1}]}
```

marshmallow_dataclass 好处是用 typehint 格式很简短可读性强

例如前者要 `id = fields.Integer()` 的字段定义，后者写成 `id: int` 即可

但要如何像 marshmallow 那样支持 `serde(rename_all="CamelCase")` 序列化后自动重命名 snake_case 为驼峰?

文档里没写，看源码得知 dataclass 装饰器/注解有个 base_schema 的入参，果然实现了反射/元编程中字段名批量转换成驼峰

```python
from marshmallow import Schema, fields, EXCLUDE
class CamelCaseSchema(Schema):
    def on_bind_field(self, field_name, field_obj):
        def camelcase(s):
            parts = iter(s.split("_"))
            return next(parts) + "".join(i.title() for i in parts)
        field_obj.data_key = camelcase(field_obj.data_key or field_name)

from marshmallow_dataclass import dataclass
from typing import List
@dataclass
class Job:
    id: int
@dataclass(base_schema=CamelCaseSchema)
class User:
    user_jobs: List[Job]
    class Meta: unknown = EXCLUDE

import json
loaded: User = User.Schema().load(json.loads('{"userJobs":[{"id":1}], "unknownField":1}'))
print(type(User), loaded)
print(User.Schema().dump(loaded))
```

总算找到一个像 serde_json 一样方便去反序列化 json 的 Python 库了，反序列化后 IDE 能自动补全出 json 的字段开发体验友好多了
