# Unsafe Rust

## variance(型变)

variance定义: 根据原始类型的子类型关系(例如Cat和Animal)确定复杂类型(例如Vec<Cat>)的子类型关系的规则

variance一般可以分为三类:

- 协变(covariant): Vec<Cat>也是Vec<Animal>的子类型
- 逆变(contravariant): 反过来Vec<Animal>是Vec<Cat>的子类型
- 不变(invariant): 既不保持又不逆转关系 => Vec<Animal>和Vec<Cat>没有任何关系

Rust中大部分结构体默认都是协变的

### PhantomData


## std::mem::transmute

TODO

## 强制take结构体的某个字段的方法

```rust
let s = replace(data.s, unsafe {mem::uninitialized()});
mem::forget(data);
```