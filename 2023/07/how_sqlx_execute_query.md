# [sqlx 如何执行查询](/2023/07/how_sqlx_execute_query.md)

虽然我之前就是 sqlx contributor 但直到最近我给国产数据库实现 sqlx driver 结合我积累更多数据库背景知识才算深入理解 sqlx 查询执行过程，做下笔记记录下

以 `query_as::<_, (i32,)>("select ?").bind(1i32)` 为例来讲解

## encode/decode

无论是 sqlite 还是 pg 数据库，**所有类型都会编码成 bytes 进行传输，例如解码时再根据 type_id 解析 bytes**

bind(1i32) 的时候 sqlx 编译时会检查该类型是否实现 Encode 和 Type

譬如你实现类型的时候代码复制粘贴完忘了改 i64 的 TypeInfo 则会在 try_decode 阶段报错

```rust
impl Type<Tydb> for i64 {
    fn type_info() -> TypeInfo {
        TypeInfo(Val::I32(0))
    }
}
```

```
// 这行在 TypeInfo::name()
[src/types/mod.rs:28] self = TypeInfo(I32(0))
[src/types/mod.rs:28] self = TypeInfo(I64(1673626724372140033))

`Err` value: ColumnDecode { index: "\"team_id\"", source: "mismatched types; Rust type `i64` (as SQL type `TypeInfo::name`) is not compatible with SQL type `TypeInfo::name`" }'
```

sqlx decode 的时候发现数据库返回的值告诉说是个 i64 类型，但是 i64 类型的 TypeInfo 缺写错成 i32

这个严谨的类型判断很赞，背后是通过 TypeInfo PartialEq 去比较的

为了简单我直接用数据库值类型的 Val 包一层就成了 TypeInfo 再拿 discriminant 判别两个值是否相等忽略类型

```rust
#[derive(Clone, Debug)]
pub struct TypeInfo(pub Val);

impl PartialEq for TypeInfo {
    fn eq(&self, other: &Self) -> bool {
        std::mem::discriminant(&self.0) == std::mem::discriminant(&other.0)
    }
}
```

所以能序列化/反序列化到数据库的类型，必须实现 Type,Encode,Decode 保证类型的严谨

---

1. 数据库 prepare 的时候就能拿到 sql 返回结果的字段名称类型是否非空约束等元信息
2. prepare 后吧 .bind(1i32) 进行 encode() 后 sqlite3_bind_int
3. 执行 sql 后 fetch_many 迭代器拿结果

因为 query_as::<_ (i32,)> 返回一个元组，所以要实现 `impl sqlx_core::column::ColumnIndex<Row> for usize`

如果是返回结果存到结构体中，则是需要实现 `impl sqlx_core::column::ColumnIndex<Row> for &'_ str`

impl_encode_for_option! 这个宏可以自动给 T: Encode 实现 `Option<T: Encode>`

## 给数据库加一种数据类型

sqlx 核心的 Trait 的结构体就 `Value, TypeInfo(Value), Row(Vec<Value>), Connection` Column 可以基本不用，简单的应用场合基本用不上 Stmt

例如数据库加一个 i128 类型支持很简单

1. enum Value 加一种类型，然后实现下转换成对应数据库的 type_id, 编码解码过程
2. impl Encode/Decode/Type for i128

(sqlx 开发最让人痛苦的是 ra 检测出循环依赖导致无法静态分析 <https://github.com/rust-lang/cargo/issues/8734>)

```
[ERROR project_model::workspace] cyclic deps: sqlx_core(Idx::<CrateData>(304)) -> sqlx(Idx::<CrateData>(268)), alternative path: sqlx(Idx::<CrateData>(268)) -> sqlx_core(Idx::<CrateData>(304))
[ERROR project_model::workspace] cyclic deps: sqlx_sqlite(Idx::<CrateData>(327)) -> sqlx(Idx::<CrateData>(268)), alternative path: sqlx(Idx::<CrateData>(268)) -> sqlx_macros(Idx::<CrateData>(321)) -> sqlx_macros_core(Idx::<CrateData>(323)) -> sqlx_sqlite(Idx::<CrateData>(327))
[ERROR project_model::workspace] cyclic deps: sqlx_test(Idx::<CrateData>(328)) -> sqlx(Idx::<CrateData>(268)), alternative path: sqlx(Idx::<CrateData>(268)) -> sqlx_test(Idx::<CrateData>(328))
```
