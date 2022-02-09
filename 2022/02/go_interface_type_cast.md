# [go interface cast](2022/02/go_interface_cast.md)

从酷熊博客学到的 go 小知识: https://fasterthanli.me/articles/some-mistakes-rust-doesnt-catch

alternavie: Rust 里面裸指针都是带类型的，跟 C 一样只有 void* 类型可以 cast 成任意类型

Go 里面貌似只能通过函数入参将入参 cast 成 interface 类型

a, ok := a.(int) 就能将 a interface 变成 int 类型

```go
package main
import "log"
func add(a interface{}, b interface{}) interface{} {
	log.Printf("a=%v, b=%v", a, b)
	a_int, ok := a.(int)
	log.Printf("a_int=%v, ok=%v", a_int, ok)
	if ok {
		b_int, err2 := b.(int)
		log.Printf("b_int=%v, err2=%v", b_int, err2)
		if err2 {
			return a_int + b_int
		}
		return "b not a int"
	}
	return nil
}
func main() {
	log.Printf("%v", add(1, 2))
	log.Printf("%v", add(nil, 1))
	log.Printf("%v", add(1, "a"))
	log.Printf("%v", add(nil, "a"))
}
```

文章还提到，go 跟 c 一样运行 static xxx; 也就是未初始化的 static 解引用时会 segmentfault
