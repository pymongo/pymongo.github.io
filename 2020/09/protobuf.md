# [protobuf](/2020/09/protobuf.md)

protobuf是一种Google发布的一种数据传输协议/序列化格式，无论是服务端或前端序列化反序列化的性能以及压缩率都要比json优秀

我对protobuf的简评: 前后端共用一套数据结构，相比我之前做过的rails+android_gson的项目来说，protobuf基本不会遇到反序列化失败、参数字段缺失等问题，解析protobuf比解析json出错更少，配合rust的模式匹配+错误处理几乎能穷举所有可能的错误

当前protobuf的不足: Rust的类型系统要比protobuf还有丰富，例如Rust的Result在protobuf中没有更接近的表达

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

## protobuf的字段名和序号

Protobuf的Message字段名可以随意改，在传输层真正有用的是「字段序号」和「字段类型」

Google这种巧妙的设计让js/java等camcel_case命名 和 rust这样snake_case命名 即使两端字段名不同也能公用同一个proto文件

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

archlinux 安装 android-studio 时会自动装上 `protobuf` 这个包

protoc工具的用法如下

> protoc --rust_out ~/temp user.proto

protoc能静态检查proto文件的语法错误，而protobuf-codegen-pure构建则不能，例如以下错误protoc在构建时会报错

> Field number 1 has already been used in "User" by field "id"

以上报错用 protobuf-codegen-pure在编译时不会报错，vi 时则是在运行时decode会panic: "WireError(UnexpectedWireType(WireTypeLengthDelimited)"
