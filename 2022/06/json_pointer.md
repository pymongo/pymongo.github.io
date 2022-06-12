# [json pointer](/2022/06/json_pointer.md)

我们知道 ruby/python/rust/js 这类语言可以通过像字典的方式检索 json

例如 `dict["data"][0]` 获取 json 的 data 字段的第 0 项

但是对于像 C 这样没有这种语法的语言，就需要一个更通用的跨语言异构的 json 检索方式

这个在 RFC 上有个标准叫 json pointer

<https://docs.serde.rs/serde_json/value/enum.Value.html#method.pointer>
