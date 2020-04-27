# [给开源项目(scoop)提交代码](/unarchived/pull_request_to_scoop/index.md)

## 版本管理器git与SVN

常见的版本管理软件是git和SVN, 业界最常用的是git

git与SVN的最大区别在于git是分布式的, git的功能更丰富

但代码集中式的SVN利于公司「保密」, 而且SVN学习难度远低于git

降低公司培训成本, 所以我公司用的就是SVN

## scoop开源项目

github是一个以git为版本管理器的代码托管云平台

凭借着免费好用与口碑, github上面托管了很多开源项目的代码仓库

scoop是一个windows平台下的包管理软件, 类似Linux的apt-get或macOS的brew

最近我通过scoop更新sqlite的时候发现了软件的一个Bug

![01_sqlite_version](01_sqlite_version.png "01_sqlite_version")

## 正确地参与开源社区

我第一反应是上scoop的github主页看看有没有人提Pull Request(以下简称PR)或者issue

issue类似于每个项目都会有个论坛让用户发Bug的帖子, PR则是提交Bug「并提交如何解决Bug的代码」

我以前给其它开源项目提过几个issue, 由于我蹩脚英语没描述清除问题, 

浪费了作者和其他开发者的时间, 要么作者忙没看到或者看到以后也没解决问题

Linux之父曾说过"Talk is cheap, show me the code"

既然我有能力修改scoop的源代码去解决代码, 那就不用浪费时间提issue

> I am able to fix this bug, please merge my code!

## Pull Request详细步骤

由于我要修改/提交的代码量很少, 全程在github网页操作

没有在Terminal用git命令(主要是我记不住命令)

### 1. 先把别人项目fork到自己账户

![02_fork](02_fork.png "02_fork")

fork简单说就是完整地拷贝一份别人的代码, 当你改完代码后再merge合并回去

scoop这个项目超过5000人点赞/收藏, 预计上万人使用, 算个大项目了

### 2. 修复Bug「核心」

- Bug出现的文件: sqlite.json
- Bug描述: sqlite版本号写的是3.6.0实际下载的是3.5.3
- 出现原因: 可能是scoop的网络爬虫没爬取最新的sqlite下载地址
- 如何修复: 更正下载地址和相应的哈希值

熟悉HTTP的GET方法的我, 轻松就发现sqlite官网下载链接的规律

我把下载链接末尾的`3250300.zip`改为`3260000.zip`果然成功了

改好下载地址后, 接下来是要更新相应的哈希值

我把原本的哈希值送进python的len函数测出哈希值长度是64位的16进制

64位的16进制正是256位二进制, 说明用的是sha256算法, sha256sum是Linux自带命令很快算出新的哈希值

![03_sha256sum](03_sha256sum.png "03_sha256sum")

### 3. commit代码后提PR

github网页版可以在线修改代码, 然后commit到自己账户下刚刚fork过来的scoop账户

然后github就会提醒你 `This branch is 1 commit ahead of 原作者:master`

大意是我的scoop项目版本比原作者版本领先1个版本

如果这时候原作者或者其它人也修改了这部分的代码准备PR, 

就会产生分支冲突, 这时原作者就需要手动修改冲突部分代码

我commit到自己账户后, 回到原项目, 提出了PR

![04_pull_request](04_pull_request.png "04_pull_request")

---

PR提交完后就出现在项目的PR清单, github告诉我, 我的PR没有检测出分支冲突

![05_pull_requests_list](05_pull_requests_list.png "05_pull_requests_list")

现在就耐心等待作者看到后, 决定是否把我的代码加到他项目里

由于时差关系, 我提交PR这回老外都在睡觉, 但愿我蹩脚英语写出的PR描述能让他们看懂

### 4. 作者merged my commit

8个小时后, 我收到邮件提醒我给scoop项目提交的代码通过作者的审核了!

![06_merged](06_merged.png "06_merged")

## 总结

我的commit的标题是 `update sqlite url and hash from 3.5.3 to 3.6.0`

作者把commit标题改为 `sqlite: fix hash and URL for version 3.6.0`

下图是最终的commit文件差分/修改结果以及commit信息

![07_commit_file_diff](07_commit_file_diff.png "07_commit_file_diff")

scoop项目8000多次的commit, 离不开作者无私奉献, 也离不开像我这样的热心用户给项目PR修改代码

开源社区, 为人类更美好的未来而努力!

后记：除了sqlite我给作者提过PR，7zip也提过(中间还改错一个地方...)
