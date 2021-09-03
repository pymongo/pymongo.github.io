# [protobuf](/2020/09/protobuf.md)

protobuf 是一种 Google 发布的一种数据传输协议/序列化格式，序列化的性能和压缩率都要比 json 优秀

而且是强类型约束，避免了 json 中发送方如果漏掉字段导致接收端字段缺失报错

json 传输时字段的 key 是一个字符串，增大了数据包体积，而 protobuf 字段的 key 是一个 i32 体积远远小于 json 的 String key
## protobuf 字段编号的另一优点

除了体积小，还方便开发对字段随意重命名，只要字段的序号不变即可

所以 JavaScript 可以将字段命名成 camel case 而 Rust 则可以命名成下划线表达式

## protobuf 的不足

好像 protobuf3 去掉了 optional 的支持，除了 primitive type 全是 option

- 除了 primitive type 必须 non-null，其它类型都是 Option can be unset
- 没有 u8, [u8; 4] 等类型
- 没有 Result 类型，oneof 不如 enum 好用

## proto code gen

Rust 生态主要 rust-protobuf 和 tokio 的 prost/tonic-build 两种

rust-protobuf 生成的代码行数远多余 prost

因为 rust-protobuf 会生成每个字段的 getter/setter 且为了支持 serde 多了很多代码

### protoc/rust-protobuf

可以通过 protoc 编译 proto 文件这样很方便的查看警告

> protoc src/rpc/protos/common.proto --proto_path=src/rpc/protos --fatal_warnings --rust_out target/

protoc 能静态检查 proto 文件的语法错误，而 protobuf-codegen-pure 构建则不能，例如以下错误 protoc 在构建时会报错

> Field number 1 has already been used in "User" by field "id"

以上报错用 protobuf-codegen-pure 在编译时不会报错，则是在运行时decode会panic: "WireError(UnexpectedWireType(WireTypeLengthDelimited)"

或者在 build.rs 中编译 proto

```rust
protobuf_codegen_pure::Codegen::new()
    .customize(protobuf_codegen_pure::Customize::default())
    .out_dir("src/protos")
    .input("src/protos/user.proto")
    .include("src/protos")
    .run()
    .unwrap();
```

rust-protobuf 主要用 write_to_bytes/parse_from_bytes 进行序列化/反序列化

rust-protobuf 可惜是难以生成 rpc 相关代码

### prost/tonic-build

tonic-build 是基于 prost，可以将 rpc 相关代码生成为一个 async trait service
