# [解决no field on type `&T`](/2020/06/generic_error_no_field_on_type_t.md)

在Rust代码的API服务器中，每个接口的表单都是一个不同的结构体

假如每个接口都需要进行数字签名检验这种相同操作，我的建议是通过泛型实现代码复用

```rust
pub trait Form {
    fn valid_params(&self) -> bool;
}

pub async fn common_valid_params<T>(
    form: &T,
    db_pool: &MySqlPool,
) -> Result<bool, HttpResponse>
where
    T: Signature,
    T: std::fmt::Debug,
{
    info!("{:?}", form);
    // 直接form.lang获取结构体字段会报错
    debug_assert!(vec!["zh", "en"].contains(&form.lang));

    if form.valid_params {
        // ...
    }
    
    Ok(true)
}
```

## where语句

首先解释下Rust的where语句

fn test(form: &T) where T: Form

可以缩写为

fn test<T: Form>(form: &T)

where
    T: Signature,
    T: std::fmt::Debug,
    
可以缩写为

where
    T: Signature + std::fmt::Debug,
    
所以where语句的作用就是指明泛型T都有哪些Trait

有点像多继承或mixin机制了：为了格式化打印表单，T需要实现Debug Trait; 为了验证参数，T需要实现Form trait

## 泛型trait的getter方法

在泛型函数内，无法直接获取到泛型入参的各参数，会报错`no field on type T`

例如我想获取表单的lang字段，那么需要在Form Trait写一个get_lang()的getter方法

显然，如果每个表单的每个字段都要写个getter方法实现冗余

可以通过derive过程宏，以元编程的方式自动生成这些Boilerplate code

[可以看Rust反序列化库作者写的derive过程宏Example](https://github.com/dtolnay/syn/tree/master/examples/heapsize)
