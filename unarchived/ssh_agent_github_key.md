# 生产服务器使用ssh-agent获取开发环境的github密钥去拉代码

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
4. [可选?]`ssh-add ~/.ssh/id_rsa`将密钥加到ssh-agent中

配置完上述操作后，即便ssh-agent没有开启，ssh -a时也会自动启动`/usr/bin/ssh-agent -l`
