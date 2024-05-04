# [bincode2改动](/2024/05/bincode2_review.md)

bincode 2.0 整数默认用类似protobuf的变长编码，我用bincode2序列化会比1.0版本小20%

2.0为了性能放弃serde改用自家的Encode trait
