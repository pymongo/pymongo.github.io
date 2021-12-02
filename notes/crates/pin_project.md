pin_project 中 project 的含义是 projection(依赖注入)

消除实现 Pin 这样的 boilerplate code

方便获取从 `&mut` -> `Pin<&mut Self>` 的转换 (通过 .project() )

> let inner: Pin<&mut R> = unsafe { self.map_unchecked_mut(|x| &mut x.inner) };

if inner field is `#[pin]`

> let inner = self.project().inner;

pin_project! 宏给没有实现 !Unpin 的结构体的某些字段统一实现下(标准库的类型几乎都是 Unpin)

