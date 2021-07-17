# [aur 回滚包/指定安装版本/404 等问题](/2021/07/aur_rollback_downgrade_package.md)

mongodb-compass 1.28.0-1 版有 Bug 在 archlinux 上启动时会卡死

最简单的解决方案就是回滚到上一个版本，然后 yay 更新的时候手动忽略 mongodb-compass 的更新

```
git clone https://aur.archlinux.org/mongodb-compass.git/
cd mongodb-compass
git reset 7cb7d196ab577f6b2d76a4574023423ee6843243
makepkg # generate xxx.pkg.tar.zst by PKGBUILD
sudo pacman -U mongodb-compass-1.27.1-1-x86_64.pkg.tar.zst
```

## pacman/yay 忽略某个包的更新

```
[options]
IgnorePkg = mongodb-compass
IgnorePkg = libcurl-openssl-1.0
```

## 针对 github archive 下载链接 404 的 aur 包

例如: debtap, processing

同样可以 clone PKGBUILD 仓库源码，然后修改 PKGBUILD

更正下载链接，并且修改下载文件的 sha256sum

然后 makepkg 之后手动安装

另一种更好的解决方案是安装 xxx-git 版软件，例如 uftrace-git 就不会有 github 下载链接 404 的问题了

## 「案例」processing 404 的解决版本

processing 是一个 UI 类似 arduino 的 2D Java 变成画图软件

```diff
-source=("https://github.com/$pkgname/$pkgname/archive/$pkgname-0$((266+${pkgver##3.5.}))-$pkgver.tar.gz"
+source=("https://github.com/processing/processing/releases/download/processing-0270-3.5.4/processing-3.5.4-linux64.tgz"
         'https://download.processing.org/reference.zip'
         build.xml
         errormessage.patch)
-sha256sums=('99a5d3cfccd106e79fe82cafa66b72b15c19e5747eac77e40dd0a82b032c2925'
+sha256sums=('ded445069db3c6fc384fe4da89ca7aa7d0a4bd2536c5aa8de3fa4e115de3025b'
```

虽然以下 patch 的问题没解决，但至少解决了下载链接 404 的问题

```
can't find file to patch at input line 3
Perhaps you used the wrong -p or --strip option?
The text leading up to this was:
--------------------------
|--- processing/app/src/processing/app/contrib/ContributionManager.java 2018-07-26 23:59:08.000000000 +0200
|+++ processing/app/src/processing/app/contrib/ContributionManager.java 2018-11-20 12:53:07.229171545 +0100
--------------------------
File to patch: 
Skip this patch? [y] y
Skipping patch.
1 out of 1 hunk ignored
==> ERROR: A failure occurred in prepare().
    Aborting...
```
