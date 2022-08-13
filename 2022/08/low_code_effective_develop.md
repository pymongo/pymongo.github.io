# [低代码的开发效率](/2022/08/low_code_effective_develop.md)

有同事推荐了这个 nodejs 看上去很像 graphql 的工具: <https://www.prisma.io/>

联想到有的同事说每次 migration 都要写 up.sql + down.sql 太麻烦了

我看 sea-orm 之类还支持全自动 ORM, prisma 所谓的低代码的意思是

手写一个业务的 model 有哪些字段，前端通过 graphql 这样让前端写类 SQL where order by 之类的查后端数据

所以跟 graphql 这样单个后端 API path 单接口，后端自动将 model 对应 mongodb 生成 crud 接口

用低代码快速完成接口开发，把更多时间投入到自动化测试和 CI/CD 上保证业务系统 4 个 9 可用
