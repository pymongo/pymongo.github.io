# [bigger/little/naive endian](/2020/10/little_endian_big_endian_byte_order.md)

最近我在用Rust写一个postgreSQL的client，client要发的第一条消息是StartupMessage，StartupMessage的body中第一个字节是通信协议版本

`start_up_msg_body.extend(&0x00_03_00_00_i32.to_be_bytes());`

我用`to_be_bytes`将i32的版本号数据转为[u8; 4]，我注意到还有2个相似的API: `to_le_bytes`和`to_ne_bytes`

计算机领域中大部分的数据都用<mark>bigger-endian(大端序)</mark>，所以0x100(256)在内存上的表示是\[1,0]=1*256+0

例如std::intrinsics::copy的文档上就指明: `ptr` must be correctly aligned for its type and non-zero

这里的be就是bigger-endian的缩写(Rust std源码byte order大部分都是bigger-endian)

## 注意transmute默认用naive-endian

```rust
const POSTGRES_PROTOCOL_VERSION_3: i32 = 0x00_03_00_00;
const RAW_BYTES: [u8; 4] = [0, 3, 0, 0];

let transmute_res = unsafe {
    // transmute default use os's naive endian, macOS/Linux default byte order is little-endian(LSB first, 小端序), LSB: Least Significant Bit
    // so RAW_BYTES's LSB->MSB is from left to right, LSB is RAW_BYTES[3]
    // naive-endian=little-endian: [0,3,0,0] => [0,0,3,0] = 3*256=768
    // CARGO_CFG_TARGET_ENDIAN: little
    std::mem::transmute::<[u8; 4], i32>(RAW_BYTES)
};
assert_ne!(transmute_res, POSTGRES_PROTOCOL_VERSION_3);
assert_eq!(transmute_res, i32::from_ne_bytes(RAW_BYTES));
// convert little-endian 768 to bigger-endian
assert_eq!(i32::from_be(transmute_res), POSTGRES_PROTOCOL_VERSION_3);
assert_eq!(i32::from_be_bytes(RAW_BYTES), POSTGRES_PROTOCOL_VERSION_3);
```

transmute只能用naive-endian的字节序(mac/linux上naive-endian=little-endian)，而且还是unsafe，建议用from_be_bytes代替transmute
