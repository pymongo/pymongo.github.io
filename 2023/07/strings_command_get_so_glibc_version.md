# [strings 命令查 so](/2023/07/strings_command_get_so_glibc_version.md)

```
> strings /usr/lib/libfoo.so | grep @@GLIBC_2 | head
ctime@@GLIBC_2.2.5
sem_wait@@GLIBC_2.2.5
pthread_getspecific@@GLIBC_2.2.5
pthread_cond_destroy@@GLIBC_2.3.2
memset@@GLIBC_2.2.5
ftell@@GLIBC_2.2.5
wcsncpy@@GLIBC_2.2.5
shutdown@@GLIBC_2.2.5
wcslen@@GLIBC_2.2.5
abort@@GLIBC_2.2.5
```
