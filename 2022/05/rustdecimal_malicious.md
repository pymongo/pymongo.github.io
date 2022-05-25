# [rustdecimal 供应链投毒](/2022/05/rustdecimal_malicious.md)

前几个月 nodejs 社区发生了 node-ipc 的供应链投毒事件，没想到最近 rust 社区也发现了一个恶意的库且官方博客专门发文警告

Rust 官方的回应是删库+扫描所有 crate 看看有没有类似 rustdecimal 的恶意代码

## 词汇积累

文中很多词汇都是安全领域的术语，可以积累下

|||
|---|---|
|malicious|恶意的|
|malware|恶意的|
|malware|恶意的|
|victims|受害者|
|squatting|蹲着(typosquatting 表示蹲守用户单词拼错的攻击)|
