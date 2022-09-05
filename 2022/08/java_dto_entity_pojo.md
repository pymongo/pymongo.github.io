# [DTO 等命名术语](/2022/08/java_dto_entity_pojo.md)

本文记录的 DTO,entity 等术语都是 Java 生态的一些常见命名，记录下作为笔记以后方便查询

||||
|---|---|---|
|DTO|Data Transfer Object|前端请求 json 反序列化后的结构体|
|POJO|Plain Old Java Objects|同义词是 Bean，除 getter/setter 外无任何方法的结构体|
|entity||字段跟数据库表一一对应|
|DAO|Data Access Object|数据库表 CRUD 的 interface, 参考 room 框架|
|PO|Persistent Object|ORM 插入参数/查询返回的结构体|
|VO|Value Object|业务层内部传输用的纯数据结构体|
