# 英语积累

## cluster集群

来源: [redis commands](https://redis.io/commands)

## vulnerabilities脆弱

例句：DOM-based cross-site scripting is one of the most common security vulnerabilities on the web

来源：[New in Chrome 83](https://developers.google.com/web/updates/2020/05/nic83)

## succeeding后继地

链表/二叉树之类数据结构中常用单词，pred=predecessor, succ=successor

二叉树的莫里斯遍历/线索二叉树中的高频词

来源1: [rust的日期时间库chrono中获取明天日期的API](https://docs.rs/chrono/0.3.0/chrono/date/struct.Date.html#method.succ)

来源2: [Morris traversal for Preorder](https://www.geeksforgeeks.org/morris-traversal-for-preorder/)

## transitions变动

例句: After an Actor's started() method is called, the actor transitions to the Running state

来源: [Actix Book](https://actix.rs/book/actix/sec-2-actor.html)

## i.e. 也就是

例句: All addresses to the actor get dropped. i.e. no other actor references it.

来源: [Actix Book](https://actix.rs/book/actix/sec-2-actor.html) 

## denote表示

## adjacent_matrix邻接矩阵

## laying off employees裁员

## aggregate合计

## shrinks收缩

## CI/CD(Continuous Integration/Deployment)

## hilarious欢闹地

- pervade: 弥漫
- cafeteria: 自助餐厅

---

## 短语收集

## 系统编程/安全领域高频词

- intrinsic: 内在地
- vulnerable to xxx: 易于收到xxx的攻击
- evolved from xxx: 从xxx发展而来 
- sabotage: 破坏

## 技术类高频词

- retrieve: 恢复
- Boilerplate code: 样板代码
- Primitive type: 原始类型(例如Java的int等等)
- implicitly: 隐含地
- explicitly: 显示的
- intentional: 故意的
- elision: 省略
- sentinel: 哨兵(sentinel value for NULL)
- first-class citizen: 一等公民


manipulation: 操作行为  
corresponding: 一致的

Rust map.entry() API

> Gets the given key's corresponding entry in the map for in-place manipulation


### 已掌握的技术类高频词

- middleware: 中间件

---

## 软件工程和软件版本相关

[This seems to be a regression from #214.](https://github.com/launchbadge/sqlx/pull/630)

上下文: sqlx在一次重构url parser的commit后，db_url中不能携带non-ASCII的字符，老版本还是可以的，作者认为PR#214对db_url密码的解析是一种(regression倒退)

---

## Rust RFC高频词

- IR(Intermediate representation): rust_code -> HIR -> MIR -> LLVM IR -> LLVM IR optimize -> target_plaform_machine_code


#[derive(serde::Deserialize)]
struct CommitInfo {
    hash: String,
    date: String,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cmd_output = std::process::Command::new("git")
        .arg("log")
        .arg("-1")
        .arg("--pretty=format:{ \"hash\":\"%h\", \"date\":\"%ad\" }")
        .output()?;
    let commit_str = String::from_utf8(cmd_output.stdout)?;
    let commit: CommitInfo = serde_json::from_str(&commit_str)?;
    // send env-var COMMIT_HASH and COMMIT_DATE to compile-time, receive by src/logger.rs
    println!("cargo:rustc-env={}={}", "COMMIT_HASH", commit.hash);
    println!("cargo:rustc-env={}={}", "COMMIT_DATE", commit.date);
    Ok(())
}



#!/bin/bash

set -o xtrace # print command before execute
declare -a folders=("igb-db" "igb-common" "igb-tests" "igb-server" "igb-helper-bot" "igb-bot-server")
for folder in "${folders[@]}"
do
  # using a subshell to avoid having to cd back
  (
    cd "$folder" || exit # exit if cd failed
    cargo fmt
    cargo build
    cargo clippy
    cargo udeps
    #cargo build --release
    #cargo udeps --release
  )
done
