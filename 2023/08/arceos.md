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
