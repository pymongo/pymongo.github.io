# [const Decimal](/2024/03/rust_decimal_const.md)

rust 生态使用量第一的 Decimal 有 rust_decimal 性能最差的 bigdecimal-rs 还有国人的 decimal-rs 和 materializeinc 数据库的 dec-rs

由于 decimal 初始化往往要检查精度是否溢出等等，所以很难提供 const new, decimal-rs 的 const from_raw_parts 是 unsafe 的 rust_decimal 的 from_parts 是私有的

于是我在想能不能用 unsafe 绕过私有字段的限制

```rust
pub(crate) const fn decimal_const_from_u32(val: u32) -> Decimal {
    union Transmute {
        t: Decimal,
        u: (u32, u32, u32, u32),
    }
    unsafe { Transmute { u: (0, 0, val, 0) }.t }
}
```

但 rust_decimal 在 github 跟我说可以用 dec! 宏创建常量 Decimal 我试了下果然不错比 Decimal new 可读性好太多了
