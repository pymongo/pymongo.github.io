# [Rust通过dyn实现多态](/2020/09/rust_polymorphism.md)

谈到多态，我还以为要想Java那样继承父类之后向上塑型(upcast)才算多态，

殊不知Rust的Trait其实就已经实现多态了

> 多态存在的三个必要条件. 继承; 重写; 父类引用指向子类对象

多态是一种泛型技术，使用不变的代码来实现可变的算法，多态为不同数据类型的实体提供统一的接口   

于是试着写一下Rust多态的代码，我在一个数组里存各种不同的Animal

```rust
trait Animal {
    fn eat(&self);
}

struct Cat;

impl Animal for Cat {
    fn eat(&self) {
        println!("Cat is eating");
    }
}

struct Dog;

impl Animal for Dog {
    fn eat(&self) {
        println!("Dog is eating");
    }
}

fn main() {
    let cat = Cat{};
    let dog = Dog{};
    let animals = vec![cat, dog];
}
```

然后编译时就报错了: 

> error[E0308]: mismatched types: expected struct `Cat`, found struct `Dog`

## dyn关键字实现多态

我理解的多态是泛型编程的一种实现方法

例如可以让一个数组存不同类型的动物，遍历结构体调用动物的eat()方法得到的结果都不同，或者有一个函数能以动物作为入参

在Java里可以通过向上塑型让不同动物都cast成Animal类，得以通过类型检查

Rust没有继承, trait A : B 实际上是给A加上一个约束条件: implement B also need to implement A

所以Rust实现多态是以下方式:

```rust
trait Animal: Any {
    fn eat(&self);
}

struct Cat;

impl Animal for Cat {
    fn eat(&self) {
        println!("Cat is eating");
    }
}

struct Dog;

impl Animal for Dog {
    fn eat(&self) {
        println!("Dog is eating");
    }
}

fn make_animal_eating(animal: &dyn Animal) {
    animal.eat();
}

fn main() {
    make_animal_eating(&Cat{});
    make_animal_eating(&Dog{});
    // cat和dog实例需要分配在堆内存中才能装入Vec，否则会报错: Sized is not known at compile time
    let cat = Box::new(Cat{});
    let dog = Box::new(Dog{});
    let animals: Vec<Box<dyn Animal>> = vec![cat, dog];
    for animal in animals {
        animal.eat();
    }
}
```

所以陈皓博客上《Rust的编程范式文章》里提到`让 IShape 继承于 Any`是不准确的

而且介绍Rust的upcast实现多态也很多余，通过dyn实现多态多简单啊

## 使用valgrind检查内存泄露

```
root@iZ2zeeb8mcpt9xrj6zqa9pZ:~/polymorphism# valgrind ./a.out 
==6789== Memcheck, a memory error detector
==6789== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==6789== Using Valgrind-3.13.0 and LibVEX; rerun with -h for copyright info
==6789== Command: ./a.out
==6789== 
Cat is eating
Dog is eating
==6789== 
==6789== HEAP SUMMARY:
==6789==     in use at exit: 0 bytes in 0 blocks
==6789==   total heap usage: 2 allocs, 2 frees, 73,728 bytes allocated
==6789== 
==6789== All heap blocks were freed -- no leaks are possible
==6789== 
==6789== For counts of detected and suppressed errors, rerun with: -v
==6789== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)



root@iZ2zeeb8mcpt9xrj6zqa9pZ:~/polymorphism# valgrind ./rust_poly 
==6801== Memcheck, a memory error detector
==6801== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==6801== Using Valgrind-3.13.0 and LibVEX; rerun with -h for copyright info
==6801== Command: ./rust_poly
==6801== 
Cat is eating
[rust_poly.rs:4] std::any::type_name::<Self>() = "rust_poly::Cat"
[rust_poly.rs:5] std::mem::size_of::<&Self>() = 8
[rust_poly.rs:6] std::mem::size_of_val(&self) = 8
Dog is eating
[rust_poly.rs:4] std::any::type_name::<Self>() = "rust_poly::Dog"
[rust_poly.rs:5] std::mem::size_of::<&Self>() = 8
[rust_poly.rs:6] std::mem::size_of_val(&self) = 8
==6801== 
==6801== HEAP SUMMARY:
==6801==     in use at exit: 0 bytes in 0 blocks
==6801==   total heap usage: 19 allocs, 19 frees, 3,473 bytes allocated
==6801== 
==6801== All heap blocks were freed -- no leaks are possible
==6801== 
==6801== For counts of detected and suppressed errors, rerun with: -v
==6801== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```
