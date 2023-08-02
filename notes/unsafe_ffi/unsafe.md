# Unsafe Rust

## variance(型变)

variance定义: 根据原始类型的子类型关系(例如Cat和Animal)确定复杂类型(例如Vec<Cat>)的子类型关系的规则

variance一般可以分为三类:

- 协变(covariant): Vec<Cat>也是Vec<Animal>的子类型
- 逆变(contravariant): 反过来Vec<Animal>是Vec<Cat>的子类型
- 不变(invariant): 既不保持又不逆转关系 => Vec<Animal>和Vec<Cat>没有任何关系

Rust 只有生命周期体现了父子类型的概念(gpt 说 trait bound Sub: Super 也算子类型)

协变(绝大部分): 能传 'a 的也能传入 'static，生命周期短的父类型 'a 引用如果能传入函数，那么生命周期长的子类型 'static 引用也能传入

Rust 只有 fn(T) 是逆变，通过结构体加上 PhantomData 类型字段可以修改改结构体在函数作为引用入参时的生存期父子类型约束，常用的是改成逆变

1. 协变: 能传入短(父)生存期的引用，也能传入长(子)生存期的引用
2. 逆变: 能传入长生存期的引用时才能传入短的生存期引用

### 什么时候要用「逆变」

unsafe 代码(例如不可变指针强行转成可变裸指针)导致一些生命周期检查失效时，例如:

```rust
fn a<'a>(cell: &MyCell<'a i32>) {
    let new_val = 13;
    b(cell);
    // drop new_val 之后，cell 存放了指向 new_val 的指针就是悬垂指针了
}

fn b<'b>(cell: &MyCell<'b i32>, new_val: &'b i32) {
    unsafe {
        cell.val as *const i32 as *mut i32 = new_val;
    }
}
```

'a(长,子): 'b

上述代码在默认协变规则下，fn b()允许传入更长生存期'a的new_val

但是在函数b为了安全必须只能用比 'b 生存期更短的引用，也就是 'b 的子类型

逆变保证 fn b() 传入的引用生存期必须是 b' 或者 比 b' 短

这时候编译器终于能发现悬垂指针了，逆变让编译器在fn b()上正常报错: val dropped here but still borrow

## 强制take结构体的某个字段的方法

```rust
let s = replace(data.s, unsafe {mem::uninitialized()});
mem::forget(data);
```