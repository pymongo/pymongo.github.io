# [cargo ramdisk](/2022/05/cargo_ramdisk_memdisk.md)

尝试无缓存(先 cargo clean)编译 tokio+axum 的项目

```
[dependencies]
tokio = { version = "1.0", features = ["macros", "rt-multi-thread"] }
axum = "0.5"
```

在 amd 4600H 处理器上耗时 13.95s (等 6800H 出了且有 15.6 寸的电脑我还真想换一个笔记本)

没有用 cargo ramdisk 时

```
[w@localhost test_cargo_ram_disk]$ cargo clean && time cargo b -q

real	0m13.910s
```

用了 cargo ramdisk 之后

```
[w@localhost test_cargo_ram_disk]$ cargo ramdisk mount
    Mounting Trying to mount "./target"
Preprocessed 📁 The target path is "/home/w/repos/temp/test_cargo_ram_disk/./target"
Preprocessed 💳 Generated unique project id "_f--a7iKiPTarRJA1fnDI"
Preprocessed 📁 The tmpfs path is "/dev/shm/target_f--a7iKiPTarRJA1fnDI"
     Created "/dev/shm/target_f--a7iKiPTarRJA1fnDI"
     Deleted 🗑 "/home/w/repos/temp/test_cargo_ram_disk/./target"
      Linked ⛓ "/dev/shm/target_f--a7iKiPTarRJA1fnDI" -> "/home/w/repos/temp/test_cargo_ram_disk/./target"
     Success ✅ Successfully created tmpfs ramdisk at "/home/w/repos/temp/test_cargo_ram_disk/./target"
[w@localhost test_cargo_ram_disk]$ cargo clean && time cargo b -q
error: failed to remove build artifact

Caused by:
  failed to remove file `/home/w/repos/temp/test_cargo_ram_disk/target/.rustc_info.json`

Caused by:
  No such file or directory (os error 2)
[w@localhost test_cargo_ram_disk]$ stat target
stat: cannot statx 'target': No such file or directory
[w@localhost test_cargo_ram_disk]$ ls
Cargo.lock  Cargo.toml  src
[w@localhost test_cargo_ram_disk]$ stat /dev/shm/target_f--a7iKiPTarRJA1fnDI
  File: /dev/shm/target_f--a7iKiPTarRJA1fnDI
  Size: 60        	Blocks: 0          IO Block: 4096   directory
Device: 0,25	Inode: 544992      Links: 2
Access: (0775/drwxrwxr-x)  Uid: ( 1000/       w)   Gid: ( 1000/       w)
Context: unconfined_u:object_r:user_tmp_t:s0
Access: 2022-05-24 11:43:54.372209238 +0800
Modify: 2022-05-24 11:43:54.372209238 +0800
Change: 2022-05-24 11:43:54.372209238 +0800
 Birth: -
[w@localhost test_cargo_ram_disk]$ ls /dev/shm/target_f--a7iKiPTarRJA1fnDI
[w@localhost test_cargo_ram_disk]$ time cargo b -q

real	0m13.628s
user	1m3.400s
sys	0m7.696s
[w@localhost test_cargo_ram_disk]$ du -h target/
245M	target/debug/deps
```

由于 target 文件夹不到 300M 所以用了 ramdisk 并没有多大的性能提升

## ramdisk 原理

在 /dev/shm 建一个随机数生成的文件夹再软链接到项目文件目录下面的 target

一般的 操作系统的 /dev/shm 都是一个 tmpfs 的 Mount point

但我用起来感觉这个 /dev/shm 的内存上的 tmpfs 并没比 nvme 的 ext4/brtfs 快多少
