# [Rust读配置文件的思考](/2020/09/rust_best_practise_load_config_file.md)

## 编译时和运行时不一样的环境变量

我最近再次阅读Rust的env!宏，发现区分了运行时和编译时的环境变量

env!宏指的是编译时的环境变量

那么我能不能这么做？编译时在build.rs读取配置文件，解析DATABASE_URL并写入到环境变量中，然后就可以用sqlx对所有SQL语句进行compile-time check了

log的其它姿势: Linux syslog通过UDP特定端口存储log，另一个姿势是使用专用的log服务器

dotenv不好的几点:

1. 把配置项加载到环境变量后，并不会回收环境变量资源
2. 没有类型约束报错信息不友好(not present)，toml的报错是missing key xxx
3. dotenv不支持option/嵌套等，没有对配置项的字段进行强制约束

工作中我遇过好多Ruby项目因为新增或修改老的kv配置项，导致运行时报错

所以Rust将配置文件反序列化位一个结构体就能保证toml配置文件每个字段都能设置上，否则反序列化失败

我在想这个读取配置文件的过程能不能放到「编译时」？

这样从toml文件中拼接出来的database_url可以用于sqlx的编译时sql检查？

我查阅了资料无果后就放弃了，不过Rust将toml文件反序列话为约定好的结构体，真的能约束下乱写配置文件的开发人员
