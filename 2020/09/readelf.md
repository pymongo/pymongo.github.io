# [readelf查看编译生成文件符号表](/2020/09/readelf.md)

最近看了一个[C++20 & Rust on Static vs Dynamic Generics](https://www.youtube.com/watch?v=olM7o_oYML0)

学到了一招用readelf去查看虚函数表符号的工具

在Linux上可以通过readelf工具查看Rust/C++编译生成的二进制文件或so文件的函数签名和符号

是一个帮助学习虚函数表、多态的工具

```rust
trait Animal {
    fn eat(&self);
    fn print_type_name(&self) {
        dbg!(std::any::type_name::<Self>());
        dbg!(std::mem::size_of::<&Self>());
        dbg!(std::mem::size_of_val(&self));
    }
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

fn static_eat<T: Animal>(a: &T) {
    a.eat();
    a.print_type_name();
}

fn dyn_eat(a: &dyn Animal) {
    a.eat();
    a.print_type_name();
}

fn main() {
    let cat = Cat;
    let dog = Dog;
    static_eat(&cat);
    dyn_eat(&dog);
}
```

上面这段Rust静态分发和动态分发的代码通过`readelf -a rust_poly | grep rust_poly`能得到以下符号:

```
    61: 0000000000005950    78 FUNC    LOCAL  DEFAULT   14 _ZN52_$LT$rust_poly..Cat$
    62: 00000000000059a0    78 FUNC    LOCAL  DEFAULT   14 _ZN52_$LT$rust_poly..Dog$
    63: 00000000000059f0    21 FUNC    LOCAL  DEFAULT   14 _ZN9rust_poly10static_eat
    64: 0000000000005a40    42 FUNC    LOCAL  DEFAULT   14 _ZN9rust_poly4main17h6ae5
    65: 0000000000004d30  1539 FUNC    LOCAL  DEFAULT   14 _ZN9rust_poly6Animal15pri
    66: 0000000000005340  1539 FUNC    LOCAL  DEFAULT   14 _ZN9rust_poly6Animal15pri
    67: 0000000000005a10    35 FUNC    LOCAL  DEFAULT   14 _ZN9rust_poly7dyn_eat17hf
```

再举一个C++的例子，下面是一段多态的代码

```cpp
#include <iostream>
using std::cout;

struct Animal {
	virtual void eat() = 0;
};

struct Dog: Animal {
	void eat() override {
		cout << "Dog is eating\n";
	}	
};

struct Cat: Animal {
	void eat() override {
		cout << "Cat is eating\n";
	}	
};

void dyn_eat(Animal& a) {
	a.eat();
}

int main() {
	Cat cat;
	Dog dog;
	dyn_eat(cat);
	dyn_eat(dog);
	return 0;
}
```

`readelf -a a.out | grep eat`之后能得到

```
    39: 0000000000000af5    21 FUNC    LOCAL  DEFAULT   14 _GLOBAL__sub_I__Z7dyn_eat
    54: 0000000000000a2a    34 FUNC    GLOBAL DEFAULT   14 _Z7dyn_eatR6Animal
    64: 0000000000000b2c    34 FUNC    WEAK   DEFAULT   14 _ZN3Cat3eatEv
    84: 0000000000000b0a    34 FUNC    WEAK   DEFAULT   14 _ZN3Dog3eatEv
```
