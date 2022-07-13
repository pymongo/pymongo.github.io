# [us3 体验](/2022/07/us3.md)

主要有三个配置:

- accesskey
- secretkey
- endpoint

例如新增了 mysite 配置后，建议 `us3cli config --su mysite` 改成默认配置

例如 endpoint 是 beijing.ufileos.com 则 bucket 会拼在域名上如:

`bucket.beijing.ufileos.com`

相比之下 aws s3 似乎喜欢将 bucket 拼接在路径上

上传文件则:

> us3cli cp a.whl us3://bucket/folder/a.whl
