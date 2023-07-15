# [ffi void** SIGSEGV](/2023/07/ffi_bind_void**_sigsegv_case_study.md)

这个 C 函数 `HandleAlloc(void **hndlpp)` ffi 我遇到了 SIGSEGV 积累下解决该问题的经验

以下是 C 那边的调用示例

```c
// define
struct Ctx; void HandleAlloc(void **hndlpp);

// call
static Ctx *p_ctx = NULL;
HandleAlloc((void**)&p_ctx);
```

我一开始写法是

```rust
let mut p_ctx = std::mem::zeroed::<Ctx>();
HandleAlloc(&mut (&mut p_ctx as *mut Ctx as *mut c_void));
```

但发现无论怎么改指针 cast 部分代码只要用 mem::zeroed 就必挂

其实 void** 就是二重指针，指针的指针

没办法只能按着 C 调用示例一模一样的写法 把 `&mut *mut Ctx` cast 成 c_void 即可

```rust
let mut p_ctx: *mut Ctx = std::ptr::null_mut::<Ctx>();
HandleAlloc( (&mut p_ctx as *mut *mut Ctx) as *mut *mut c_void );
// or
HandleAlloc( (&mut p_ctx as *mut *mut Ctx).cast() );
```

只有上述一种 cast 写法是对的，以下两种**错误写法**均会 core dumped

```rust
// both error
HandleAlloc( (&mut (p_ctx as *mut c_void) ) as *mut *mut c_void );
HandleAlloc( (p_ctx as *mut c_void) as *mut *mut c_void );
```

我又尝试打印正确和错误情况的指针地址，

错误示例中先转 c_void 再取引用一旦自身类型跟 c_void 的 usize 大小不一致就会导致指针偏移量错误

```rust
println!("&mut p_stmt={:p}", &mut p_stmt);
println!("&mut p_stmt as *mut *mut KCIStmt = {:p}", &mut p_stmt as *mut *mut KCIStmt);
println!("&mut (p_stmt as *mut c_void) = {:p}", &mut (p_stmt as *mut c_void));

&mut p_stmt=0x7ffd0f951308
&mut p_stmt as *mut *mut KCIStmt = 0x7ffd0f951308
&mut p_stmt as *mut *mut KCIStmt = 0x7ffd0f951428

dbg!(&mut p_stmt as *mut *mut KCIStmt as usize);
dbg!(&mut (p_stmt as *mut c_void) as *mut *mut c_void as usize);
dbg!(std::mem::size_of::<KCIStmt>());
```

反正只建议二重指针最终 cast 一次 c_void 千万别中途多次 cast c_void 长经验了以后注意下这两种写法得到的指针地址不一样

---

这是我的 prompt 看看 gpt 的解释

Here is a C lib define `struct Ctx; void HandleAlloc(void **hndlpp);`

Here is the Rust ffi success call

```rust
let mut p_ctx: *mut Ctx = std::ptr::null_mut::<Ctx>();
HandleAlloc((&mut p_ctx as *mut *mut Ctx) as *mut *mut c_void));
```

Here is the Rust ffi fail SIGSEGV call

```rust
let mut p_ctx: *mut Ctx = std::ptr::null_mut::<Ctx>();
HandleAlloc((&mut (p_ctx as *mut c_void) ) as *mut *mut c_void);
```

Why first rust ffi call would success while second one would fail?

gpt:

```
The first Rust FFI call succeeds because it correctly converts the mutable reference &mut p_ctx into a double pointer *mut *mut Ctx using the as keyword. The as keyword is used to perform type casting. By explicitly specifying the target type as *mut *mut Ctx, the conversion is done properly.

On the other hand, the second Rust FFI call fails and results in a SIGSEGV (segmentation fault) because of incorrect type casting. In this call, p_ctx is already a double pointer *mut Ctx, but it is casted directly to a single pointer *mut c_void. This misalignment of types causes an invalid memory access when HandleAlloc tries to dereference the incorrectly casted pointer, resulting in a segmentation fault.
```
