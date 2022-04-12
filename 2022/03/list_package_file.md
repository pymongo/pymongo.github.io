# [package file list](/2022/03/list_package_file.md)

## package file list

```
pacman -Ql bcc
yum/dnf repoquery -l bcc
```

## which package contains file

`pacman -F` or `dnf provides`

```
[w@ww temp]$ pacman -F libssl.so
core/openssl 1.1.1.m-1 [installed]
    usr/lib/libssl.so
core/openssl-1.0 1.0.2.u-1
    usr/lib/openssl-1.0/libssl.so
community/cuda-tools 11.6.0-1
    opt/cuda/nsight_compute/host/linux-desktop-glibc_2_11_3-x64/libssl.so
    opt/cuda/nsight_systems/host-linux-x64/libssl.so
community/libressl 3.4.2-1
    usr/lib/libressl/libssl.so
multilib/lib32-openssl 1:1.1.1.m-1 [installed]
    usr/lib32/libssl.so
multilib/lib32-openssl-1.0 1.0.2.u-1
    usr/lib32/openssl-1.0/libssl.so
```
