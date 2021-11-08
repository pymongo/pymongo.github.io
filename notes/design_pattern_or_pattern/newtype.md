# NewType pattern

newtype 模式中被 `struct xxx()` 包起来的类型必须是 private 的，让调用方 .0 这么访问不方便也不符号**封装**的设计

## 常见于 Stmt::Item(ItemStrut)

可以用正则表达式去搜 NewType 模式/编程范式结构体的定义:

> `struct \w+\(\w+\);`
## 作用

### 作用 1. 为第三方库类型实现 derive/impl 或方法
用 ext 模式只能实现定制方法，不能为第三方库类型 impl 另一个第三方库的 trait

### 作用 2. 数据解耦

需求例子: 项目下有 db, api 两个 crate，想共用一个 User 结构体

```rust
// crates/db/src/models.rs:
#[derive(sqlx::FromSqlx)]
struct User {
    id: 1
}
```

不用 NewType 的话，比较简便的写法是将 User model 定义在 common crate，然后让 db 和 api 两个 crate 去

```rust
// crates/common/src/models.rs:
#[derive(sqlx::FromSqlx, poem_openapi::Object)]
struct User {
    id: 1
}
```

但这样写耦合性太强，一个数据库的 model 居然为了通用要引入 poem web 框架的依赖不符合 DDD 设计

推荐写法是(用 DDD 这样写也有弊端是很多格式转换或重复 impl 的冗余代码):
1. common/domain crate 里面是干净没有任何 derive 的结构体，然后 db 和 api 分别用 newtype 将 User 包过来
2. api 用 newtype 将 db 中的 User 包过来并自行 derive 上 poem 的 trait

### 作用 3. 语义上区分数据单位
例子 3.

```rust
struct Rmb(f64);
struct Usd(f64);
```

## NewType 加上 Deref 更简便
结构体包一层的模板代码，可以用 Deref trait 自动解引用让这层抽象对调用者来说是透明的

例如给 `NewType(Vec<u8>)` 实现 Deref 之后 new_type.len() 就直接等同调用 new_type.0.len()

## transmute type to newtype
可以安全的将 u8 transmute 成 NewType(u8)，反之依然

## repr(transparent)
虽然编译器会在内存布局上将 NewType 抽象看成透明的

但如果想在 FFI 中为了方便想给 fn foo(input: NewType) 传递 u8 类型的入参则会报错

此时需要用 repr(transparent) 让 C ABI 将 NewType(u8) 看作是 u8 类型

## See Also
- std::ops::Deref
- std::mem::transmute
- repr(transparent)
- <https://wiki.haskell.org/Newtype>
