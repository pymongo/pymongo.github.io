# [acreos](/2023/08/arceos.md)

> make ARCH=aarch64 A=apps/c/helloworld LOG=trace run

运行 C 版本 helloworld 应用，参考 <http://rcore-os.cn/arceos-tutorial-book/ch01-04.html> 教程装好 musl 工具链

## unikernel
单应用操作系统，操作系统就像应用程序的库因此也叫 libOS，优点是可以去掉 MMU 虚拟内存等为了安全隔离性的功能，提升性能

了解下如何定制化禁用 MMU 分页功能

## boot table

page_table=virtual-to-physical address translation

```rust
// modules/axhal/src/platform/riscv64_qemu_virt/boot.rs
#[link_section = ".data.boot_page_table"]
static mut BOOT_PT_SV39: [u64; 512] = [0; 512];

unsafe fn init_boot_page_table() {
    // 0x8000_0000..0xc000_0000, VRWX_GAD, 1G block
    BOOT_PT_SV39[2] = (0x80000 << 10) | 0xef;
    // 0xffff_ffc0_8000_0000..0xffff_ffc0_c000_0000, VRWX_GAD, 1G block
    BOOT_PT_SV39[0x102] = (0x80000 << 10) | 0xef;
}
```

SV39 解释: three available page table formats in RISC-V: SV32, SV39, SV48

The SV39 format uses a 39-bit virtual address

### PGD, PUD, PMD

|||
|---|---|
|PGD|Page Global Directory|
|PUD|Page Upper Directory|
|PMD|Page Middle Directory|

SV39 是三级虚拟内存映射，所以是 PGD->PMD->page_table 而 SV48 是四级 PGD->PUD->PMD->page_table

## lession1 编程题 a1 答案

我一开始完全没有思路，后来有群友做出来了，看了他答案，发现他照抄了 mmu-identity 中的三个 mmu 相关的 callback

```diff
diff --git a/lesson1/mmu_alterable/Cargo.toml b/lesson1/mmu_alterable/Cargo.toml
index a5cc2b3..4f078cf 100644
--- a/lesson1/mmu_alterable/Cargo.toml
+++ b/lesson1/mmu_alterable/Cargo.toml
@@ -6,8 +6,9 @@ edition = "2021"
 # See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html
 
 [features]
-enable = []
+enable = ["dep:mmu-identity"]
 disable = []
 
 [dependencies]
 riscv = "0.10"
+mmu-identity = { path = "../mmu_identity", optional = true }
\ No newline at end of file
diff --git a/lesson1/mmu_alterable/src/lib.rs b/lesson1/mmu_alterable/src/lib.rs
index b2a15af..49ee6ec 100644
--- a/lesson1/mmu_alterable/src/lib.rs
+++ b/lesson1/mmu_alterable/src/lib.rs
@@ -2,14 +2,18 @@
 
 pub const KERNEL_BASE: usize = 0xffff_ffff_c000_0000;
 
 pub unsafe fn pre_mmu() {
-    todo!("dummy");
+    #[cfg(feature = "enable")]
+    mmu_identity::pre_mmu();
 }
 
 pub unsafe fn enable_mmu() {
-    todo!("dummy");
+    #[cfg(feature = "enable")]
+    mmu_identity::enable_mmu();
 }
 
 pub unsafe fn post_mmu() {
-    todo!("dummy");
+    #[cfg(feature = "enable")]
+    mmu_identity::post_mmu();
 }
```

## QA

> 不同的应用程序通过共享内存或网络通信交互

Unikernel 既然是单应用操作系统，那么多个操作系统怎样"共用"一个内存?像 NFS 那样共享一个存储挂载

## 内存分页两次映射

内核初始化时，先恒等映射一比一映射一小部分物理内存供内核使用

第二次映射之后才算真正启动虚拟内存(linux/arceos 都是这样)

## 为什么 allocator 不能打日志
因为打日志也涉及内存分配，在 alloc/dealloc 里面打日志会陷入无限循环，因此要注意实现的时候避免无限循环

## 作业: 实现 bump 内存分配器

```
TLSF、SLAB和Bump是三种常见的以Byte为粒度内存分配算法，适合嵌入式。

TLSF（Two-Level Segregated Fit）：TLSF是一种高效的内存分配算法，适用于嵌入式系统和实时系统。它使用了两级分割的思想，将可用内存空间划分为多个块，并按照大小进行分类。TLSF采用了分离适应性的策略，即将相似大小的分配请求分配给相同大小的存储块，以减少内存碎片化。

SLAB：SLAB是一种用于管理内核内存的算法。它将内核内存分为三个区域：SLAB、CACHE和FREE。SLAB区域用于存储已经分配的对象，CACHE区域用于存储空闲对象以便快速分配，FREE区域用于存储完全空闲的内存。SLAB算法通过提前分配和缓存对象，提高了内存分配的效率。

Bump：Bump是一种简单的内存分配算法，也被称为顺序内存分配器。它将内存视为一块连续的空间，通过不断增加分配指针的位置来分配内存。Bump算法适用于嵌入式系统和一些特定场景，其中内存分配和释放的顺序已知且固定。

这些内存分配算法在不同的场景和需求下具有不同的优势和适用性。选择适当的算法可以提高内存分配的效率和性能。
```

```
提供一个Bump算法(最简版本)，供参考
a) 关键数据成员: next指针总是指向空闲区开始位置，计数allocations记录已经分配的次数
b) 申请内存: 移动next位置指针， allocations加一，返回移动前的next
c) 释放内存: allocations减一。如果归零，复位next到起始位置。
d) 需要检查，分配和释放是否越界。
```
