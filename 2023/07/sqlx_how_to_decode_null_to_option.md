# [sqlx Null 解码源码](/2023/07/sqlx_how_to_decode_null_to_option.md)

看过些 Rust 数据库实现对 Null 处理并不优雅，例如有的是给所有基础类型都包一层 Option

sqlx 的解决很赏心悦目，通过 query_as 传入的泛型类型参数决定某字段是不是非空的相应的是否会返回 Option

## decode Option<T>

```rust
// implement `Decode` for Option<T> for all SQL types
impl<'r, DB, T> Decode<'r, DB> for Option<T>
where
    DB: Database,
    T: Decode<'r, DB>,
{
    fn decode(value: <DB as HasValueRef<'r>>::ValueRef) -> Result<Self, BoxDynError> {
        if value.is_null() {
            Ok(None)
        } else {
            Ok(Some(T::decode(value)?))
        }
    }
}
```

HasValueRef/Value 是数据库所有基本类型的枚举(Value)的引用，以下是我适配某国产数据库的 Value 定义

```rust
#[derive(Debug, Clone)]
pub enum Val {
    I32(i32),
    I64(i64),
    Str(String),
    Datetime(NaiveDateTime),
    Bool(bool),
    Null
}
impl Val {
    #[inline]
    pub fn is_null_(&self) -> bool {
        matches!(self, Self::Null)
    }
}
```

然后给 ValueRef 和 TypeInfo 实现 is_null() 就行了

sqlx_core::value::Value 虽也有 is_null() 但不会被调用，Value trait 的三个方法我都没有实现

sqlx-sqlite 中通过 sqlite3_column_type 获取类型值来判断是否非空

## encode Option<T>

sqlx_core::impl_encode_for_option!(Mydb);
