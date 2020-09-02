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
