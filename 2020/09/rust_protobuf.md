# [Rust protobuf](/2020/09/rust_protobuf.md)

protobuf是一种Google发布的一种数据传输协议/序列化格式，无论是服务端或前端序列化反序列化的性能以及压缩率都要比json优秀

## protobuf的类型

为了跨语言跨平台，protobuf是没有u8、i16这些类型的，最低支持32位整数，如有需要则可以自行定义message type

除了谷歌文档列出的protobuf类型的表格，还可以composite(复合) types例如某个字段是个结构体或枚举类型

每个Message的字段都需要编号，如果中间有某个字段在新版本中被删除了，例如编号2被删除了，那么需要用reserved 2指明编号2曾经被使用过，往后的新字段就不要用这个编号了

reserve除了可以保留旧的字段编号，还可以保留旧的字段名，让新字段另起一个名字

fixed32/64类型表示固定宽度的整数，虽然u32指明了传输时用32位，但是实际上会根据数字大小去作适应，例如数据是0-255之内就用u8

但是如果数据很大至少要用32位去表示，那么用fixed类型传输效率更高，至于sfixed的s表示signed

optional修饰的字段在字段为None时并不会像json那样设为null，而是设为相应类型的默认值，例如u32的默认值是0，

当然也可以手动指定optional为None时的默认值，例如`optional int32 user_id = 1 [default = -1]`

谷歌的protobuf文档才看了20%，应该足够看懂项目

## codegen的两种方法

第一种是参考官方的Example，写build.rs

```rust
protobuf_codegen_pure::Codegen::new()
    .customize(protobuf_codegen_pure::Customize::default())
    .out_dir("src/protos")
    .input("src/protos/user.proto")
    .include("src/protos")
    .run()
    .unwrap();
```

然后在就可以encode和decode了

```rust
use learn_protobuf::protos::user::User;
use protobuf::Message;

fn main() {
    let user_1 = User {
        id: 0,
        ..Default::default()
    };
    let user_1_encoded = user_1.write_to_bytes().unwrap();
    // Decode
    let user_2 = protobuf::parse_from_bytes::<User>(&user_1_encoded).unwrap();
    assert_eq!(user_1.id, user_2.id);
}
```

但是用protobuf-codegen-pure这个crate进行编码解码的缺点是，并不能对proto文件进行静态语法检查

另一种方法是`brew install protobuf`然后给protoc安装Rust插件`cargo install protobuf-codegen`

protoc工具的用法如下

> protoc --rust_out . user.proto

protoc能静态检查proto文件的语法错误，而protobuf-codegen-pure构建则不能，例如以下错误protoc在构建时会报错

> Field number 1 has already been used in "User" by field "id"

但是使用protobuf-codegen-pure时则是在运行时decode会panic: "WireError(UnexpectedWireType(WireTypeLengthDelimited)"
