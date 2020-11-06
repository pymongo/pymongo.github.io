[归档 - 吴翱翔的博客](/)

Contact me: os.popen@gmail.com

<!--
[我的简历](/redirect/resume.html)
原始博客站点：[pymongo.github.io](https://pymongo.github.io)
镜像1：[wuaoxiang.github.io](https://wuaoxiang.github.io)
镜像2：[aoxiangwu.github.io](https://aoxiangwu.github.io)
-->

---

## Github社区常见英文缩写

公司业务/项目代码通常是很简单的，要参与开源项目Application、Web Framework、Library等类型的开源项目去提升自我竞争力

经过不断地学习我成功在actix项目组中贡献了自己的[PR](https://github.com/actix/examples/pull/298)😄

以下是github issue/PR中老外的comment中常见的英文单词缩写

- AKA: Also Known As
- FYI: For Your Information
- AFAICT: As Far As I Can Tell
- LGTM: An acronym(首字母缩写) for "Looks Good To Me"
- In a nutshell: 简而言之
- TLDR: Too Long Didn't Read

## 代码中常见缩写

- srv -> server
- conn -> connection

---

## 未分类的笔记

### 生产服务器使用ssh-agent获取开发环境的github密钥去拉代码

为了安全考虑，生产服务器上的git配置是仅允许公钥进行拉代码

1. 将~/.ssh/id_rsa.pub中的公钥加到github账号设定的密钥部分
2. ~/.ssh/config下添加以下几行(因为用的是开发环境的SSH client，所以不用重启开发环境的sshd server)

```
Host *
	AddKeysToAgent yes
	UseKeychain yes
	IdentityFile ~/.ssh/id_rsa
```

3. `ssh-agent -s`启动开发环境的ssh-agent process
4. `ssh-add ~/.ssh/id_rsa`将密钥加到ssh-agent中

配置完上述操作后，即便ssh-agent没有开启，ssh -a时也会自动启动`/usr/bin/ssh-agent -l`
