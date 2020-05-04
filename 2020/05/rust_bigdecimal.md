# [rust BigDecimal最佳实践](/2020/05/rust_bigdecimal.md)

BigDecimal(以下简称decimal)不是Rust的primitive_type，所以没有Copy Trait，需要实现重载加减乘除运算符

下面这段是BigDecimal乘法、加法的部分实现代码

```rust
impl Mul<BigDecimal> for BigDecimal {
    type Output = BigDecimal;

    #[inline]
    fn mul(mut self, rhs: BigDecimal) -> BigDecimal {
        self.scale += rhs.scale;
        self.int_val *= rhs.int_val;
        self
    }
}

impl<'a> Add<&'a BigDecimal> for BigDecimal {
    type Output = BigDecimal;

    #[inline]
    fn add(self, rhs: &'a BigDecimal) -> BigDecimal {
        let mut lhs = self;

        match lhs.scale.cmp(&rhs.scale) {
            Ordering::Equal => {
                lhs.int_val += &rhs.int_val;
                lhs
            }
            Ordering::Less => lhs.take_and_scale(rhs.scale) + rhs,
            Ordering::Greater => rhs.with_scale(lhs.scale) + lhs,
        }
    }
}   
```

## decimal精度优化

分析上面源码可了解到，decimal的加减运算中都涉及精度比较，如果精度相同则运算过程最简单，尽量「使用相同精度」的decimal进行运算

两个decimal相乘，新decimal的精度是二者精度之和，所以「尽量少用乘法」

> Internally, BigDecimal uses a BigInt object, paired with a 64-bit integer which determines the position of the decimal point

bigdecimal结构体内部有两个u64，一个是存储数值部分，另一个是存储小数点在第几位

## 构造方法中不要用浮点数

> It is not recommended to convert a floating point number to a decimal directly

> [!TIP]
> 使用`BigDecimal::from_str("1.1").unwrap`，不要用`BigDecimal::from("1.1")`

<i class="fa fa-hashtag"></i>
python错误示例

如果是python中的decimal，decimal构造方法中使用float类型会导致运算过程中像浮点数一样出现精度丢失

```python
from decimal import Decimal
# ...
error   = Decimal(2.07) - Decimal(2.07) * Decimal(8)
correct = Decimal('2.07') - Decimal('2.07') * Decimal('8')
```

## from和from_u64

from_u32源码中调用了from_u64，from_i32源码中调用了from_i64，

实际上就from_u64和from_i64两种(from_f64不推荐使用，上面分析过了)

用`BigDecimal::from_u64(1)`和`BigDecimal::from`的性能测试

```
test from     ... bench: 64 ns/iter (+/- 11)
test from_i32 ... bench: 68 ns/iter (+/- 14)
test from_i64 ... bench: 70 ns/iter (+/- 15)
test from_u32 ... bench: 70 ns/iter (+/- 12)
test from_u64 ... bench: 73 ns/iter (+/- 3)
```

结果显示，用`BigDecimal::from`效率最高

## 单个运算符的性能

以下是性能测试代码的节选

```rust
#[bench]
fn one_operator_rhs_ref(bencher: &mut test::Bencher) {
  bencher.iter(|| {
    let price = BigDecimal::from_str("1.1").unwrap();
    let volume = BigDecimal::from(1);
    let _total = price * &volume;
  });
}

#[bench]
fn one_operator_both_ref(bencher: &mut test::Bencher) {
  // ...
  let _total = &price * &volume;
}

#[bench]
fn one_operator_lhs_borrow(bencher: &mut test::Bencher) {
  // ...
  let _total = price.borrow() * volume;
}
```

单个运算符: move、ref、borrow性能对比

```
test one_operator_both_borrow    ... bench: 503 ns/iter (+/- 80)
test one_operator_both_ref       ... bench: 506 ns/iter (+/- 87)
test one_operator_lhs_borrow     ... bench: 514 ns/iter (+/- 33)
test one_operator_lhs_ref        ... bench: 507 ns/iter (+/- 98)
test one_operator_normal         ... bench: 529 ns/iter (+/- 102)
test one_operator_rhs_borrow     ... bench: 515 ns/iter (+/- 81)
test one_operator_rhs_ref        ... bench: 530 ns/iter (+/- 88)
```

结合impl Mul源码以及测试结果得出结论：

- borrow()内部返回`&T`所以不考虑可读性，用&price比price.borrow()更好;deref()函数同理。
- 源码上看，左边是ref右边是普通的乘法运算代码最少，实际上则是运算符左边(lhs)用ref性能更好
- 源码上看，运算符左右两边都是ref，参数传递效率高，实际测试中性能最好

## decimal的move问题

```rust
let a = BigDecimal::from(1);
let b = BigDecimal::from(1);
let c = a * b;
let d = a * b; // use of moved value
```

同一个decimal变量，连续用于两个运算符中就会报错

> move occurs because `a` has type `bigdecimal::BigDecimal`, which does not implement the `Copy` trait

此时有两种解决思路，一是除了最后一次使用变量，前面出现的地方都加上clone()，或者都加上clone()

二是使用reference(以下简称ref)，除了最后一次使用变量，前面出现的地方都加上&，或者都加上&

```rust
#[bench]
fn two_mul_first_clone(bencher: &mut test::Bencher) {
  bencher.iter(|| {
    let price = BigDecimal::from_str("1.1").unwrap();
    let volume_a = BigDecimal::from(1);
    let volume_b = BigDecimal::from(1);
    let _total = price.clone() * volume_a + price * volume_b;
  });
}

#[bench]
fn two_mul_first_price_ref(bencher: &mut test::Bencher) {
  bencher.iter(|| {
    let price = BigDecimal::from_str("1.1").unwrap();
    let volume_a = BigDecimal::from(1);
    let volume_b = BigDecimal::from(1);
    let _total = &price * volume_a + price * volume_b;
  });
}

#[bench]
fn two_mul_first_price_second_price_ref(bencher: &mut test::Bencher) {
  bencher.iter(|| {
    let price = BigDecimal::from_str("1.1").unwrap();
    let volume_a = BigDecimal::from(1);
    let volume_b = BigDecimal::from(1);
    let _total = &price * volume_a + &price * volume_b;
  });
}

#[bench]
/*
test two_mul_both_ref                     ... bench:         722 ns/iter (+/- 83)
test two_mul_first_clone                  ... bench:         819 ns/iter (+/- 128)
test two_mul_first_price_ref              ... bench:         735 ns/iter (+/- 122)
test two_mul_first_price_second_price_ref ... bench:         720 ns/iter (+/- 121)
结论：运算符左边的使用指针，或者全用指针性能最好，避免使用clone
*/
fn two_mul_both_ref(bencher: &mut test::Bencher) {
  bencher.iter(|| {
    let price = BigDecimal::from_str("1.1").unwrap();
    let volume_a = BigDecimal::from(1);
    let volume_b = BigDecimal::from(1);
    let _total = &price * &volume_a + &price * &volume_b;
  });
}
```

## decimal static常量

非primitive_type的decimal只能用lazy static的方式定义成常量

```rust
lazy_static::lazy_static! {
  static ref MAX_RATIO: BigDecimal = BigDecimal::from_str("1.1").unwrap();
  static ref MIN_RATIO: BigDecimal = BigDecimal::from_str("0.9").unwrap();
}

#[bench]
fn last_price_lazy_static_ref(bencher: &mut test::Bencher) {
  bencher.iter(|| {
    let params_price = BigDecimal::from(1);
    let last_price = BigDecimal::from(1);
    if params_price > &last_price * &*MAX_RATIO || params_price < &last_price * &*MIN_RATIO {
      panic!("price > last_price*1.1 or price < last_price*0.9")
    }
  });
}
```

Rust的BigDecimal常量基本就`&*MAX`这一种写法，`*MAX`用的机会不多而且效率也不高
