# [同步forked的sqlx项目](/2020/09/sync_forked_repo.md)

今天cargo updagitte更新项目第三方库后，发现sqlx编译报错了

```
error[E0277]: the trait bound `rust_decimal::Error: std::error::Error` is not satisfied
  --> /Users/w/.cargo/git/checkouts/sqlx-f05f33ba4f5c3036/2e1658e/sqlx-core/src/mysql/types/decimal.rs:27:35
   |
27 |         Ok(value.as_str()?.parse()?)
   |                                   ^ the trait `std::error::Error` is not implemented for `rust_decimal::Error`
   |
   = note: required because of the requirements on the impl of `std::convert::From<rust_decimal::Error>` for `std::boxed::Box<dyn std::error::Error + std::marker::Send + std::marker::Sync>`
```

sqlx是我提PR数量最多的开源项目，bigdecimal-rs算我目前提过的PR中技术含量最高的(用一个小算法实现了round API)

这可是一个提PR的好机会？但首先我得先同步一下forked来的sqlx仓库

正常来说都是git pull原仓库后再push到自己的仓库就完成

但是我之前给sqlx提的PR，sqlx官方先merge了另一个人的PR再merge我的PR，导致我forked的repo时间轴不对并领先了4个额外的Merge的commit

我之前试过开新分支去提PR，能解决同步问题，但是不可能每次PR都有创建一个新分支，太不方便了

后来我通过以下操作实现了forked repo强制同步sqlx的官方repo:

1. git pull sqlx master
2. git rebase sqlx/master
3. (此时出现一个both edit，我跳过了)git rebase --skip
4. (干掉远程forked上ahead的4个merge commit)git push -f

终于出现了「This branch is even with」表示我forked的分支和master完全一样了

看来rebase sqlx/master结合push -f能强制将我forked的仓库同步到sqlx中，也不用干删掉forked仓库重新forked的傻事

然后我在通过以下命令删除了当前sqlx已经合并了且被删除的分支，以下命令能同时删除local和remote的分支

> git push origin --delete feature/mssql

## squash(压缩) commits when PR

PR时给RustMagazine时，例如编辑要求你在中文和英文之间加上空格

所以你多commit了一次去消除空格，但是这样就会出现一个PR多个commits,应该squash成一个commit

例如将最近两个commit合并成1个的步骤:

1. git reset --soft HEAD~2
2. git commit -m "add article no_std_binary"
3. git push --force

---

最后回到为什么rust_decimal会报错的问题，我通过cargo tree -d命令发现rust_decimal用的是1.8版本，但是sqlx用的是1.7版本

所以改成: `rust_decimal = "=1.7.0"`

注意"=1.7.0"会强制用1.7版，而"1.7.0"会用1.8版本 
