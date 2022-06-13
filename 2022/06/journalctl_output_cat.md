# [journal -o cat](/2022/06/journalctl_output_cat.md)

用 journalctl 看日志的时候如果应用自身日志是多行或者有颜色将看不到应用自身的颜色

> Jun 13 15:47:31 iv-ybpgv6tnk95m57j82m0d containerd[681]: time="2022-06-13T15:47:31.387507935+08:00" level=info msg="Exec process \"4dfc4694041d6a60b2541bfdca97703040360daaa3de64f87c948fc39c6a2e9b\" exits with exit code 1 and error <nil>"

如果想保留应用的原始日志输出且不需要看到 journal 的 时间+域名+pid 的前缀，可以使用 -o cat 参数

> time="2022-06-13T15:47:31.387507935+08:00" level=info msg="Exec process \"4dfc4694041d6a60b2541bfdca97703040360daaa3de64f87c948fc39c6a2e9b\" exits with exit code 1 and error <nil>"
