# [python UnicodeDecodeError](/2022/11/python_unicode_decode_error.md)

在 ubuntu 镜像中执行 python 代码 os.makedirs("中文/文件.txt") 会报错 UnicodeDecodeError: ascii codec...

locale 去查询

```
locale
LANG=
LANGUAGE=
LC_CTYPE="POSIX"
```

ENV LANG=zh_CN.UTF-8 后继续用 locale 查发现没有装中文包

```
locale: Cannot set LC_CTYPE to default locale: No such file or directory
locale: Cannot set LC_MESSAGES to default locale: No such file or directory
locale: Cannot set LC_ALL to default locale: No such file or directory
LANG=zh_CN.UTF-8
```

最终修改 Dockerfile 安装上中文包吧

```
RUN apt-get update && apt-get install -y locales && apt-get clean all
RUN locale-gen zh_CN.UTF-8
ENV LANG zh_CN.UTF-8
```
