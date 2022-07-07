# [cargo tree invert](/2021/12/cargo_tree_invert.md)

假设有这样一个需求，在 fedora 高版本(2.34)的 glibc 环境中编译出的 Rust binary 要在客户的 centos7 glibc 2.17 环境中用，由于高版本 glibc 编译出的文件在低版本 glibc 环境中用不了

可能的解决方案是 musl-gcc/musl-clang 编译器使得 binary 不会强依赖 glibc 版本，例如 TabNine 在 Linux 下的 binary 就是 musl 的

```
$ cargo b -p common --target x86_64-unknown-linux-musl
...
 $HOST = x86_64-unknown-linux-gnu
  $TARGET = x86_64-unknown-linux-musl
  openssl-sys = 0.9.72

  ', /home/w/.cargo/registry/src/rsproxy.cn-8f6827c7555bfaf8/openssl-sys-0.9.72/build/find_normal.rs:180:5
  note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
warning: build failed, waiting for other jobs to finish...
error: build failed
```

用 musl 作为编译 target 容易遇到上述 openssl-sys 的问题，通常解决方案就是换成 rust-tls

可是怎么知道项目中哪些库依赖了 openssl ?

```
$ cargo tree | grep -B5 openssl
│   │   ├── nom_pem v4.0.0
│   │   │   └── nom v4.2.3
│   │   │       └── memchr v2.4.1
│   │   │       [build-dependencies]
│   │   │       └── version_check v0.1.5
│   │   ├── openssl v0.10.38
--
│   │   │   ├── cfg-if v1.0.0
│   │   │   ├── foreign-types v0.3.2
│   │   │   │   └── foreign-types-shared v0.1.1
│   │   │   ├── libc v0.2.112
│   │   │   ├── once_cell v1.9.0
│   │   │   └── openssl-sys v0.9.72
--
    │   ├── hyper-tls v0.5.0
    │   │   ├── bytes v1.1.0
    │   │   ├── hyper v0.14.16 (*)
    │   │   ├── native-tls v0.2.8
    │   │   │   ├── log v0.4.14 (*)
    │   │   │   ├── openssl v0.10.38 (*)
    │   │   │   ├── openssl-probe v0.1.4
    │   │   │   └── openssl-sys v0.9.72 (*)
```

用 grep -B5 去看，很难找到 openssl 的"根节点"，于是可能你需要将 -B5 调整成 -B25 然后还是看不到根节点...

所以能不能将树"颠倒"过来，将 openssl 看作是根节点?这样叶子节点就是项目 Cargo.toml 引入的依赖

```
$ cargo tree --invert --package openssl-sys
openssl-sys v0.9.72
├── native-tls v0.2.8
│   ├── hyper-tls v0.5.0
│   │   └── reqwest v0.11.7
│   │       └── web v0.1.0 (/home/w/repos/company/app/src/web)
│   │           └── server v0.1.0 (/home/w/repos/company/app/src/server)
│   │       [dev-dependencies]
│   │       └── web v0.1.0 (/home/w/repos/company/app/src/web) (*)
│   ├── reqwest v0.11.7 (*)
│   └── tokio-native-tls v0.3.0
│       ├── hyper-tls v0.5.0 (*)
│       └── reqwest v0.11.7 (*)
└── openssl v0.10.38
    ├── native-tls v0.2.8 (*)
    └── osshkeys v0.5.2
        ├── common v0.1.0 (/home/w/repos/company/app/src/common)
...
```

这样一下子就找到 web 和 common 的 Cargo.toml 里有 openssl 相关依赖

以后 cargo audit 例如找到 chrono 有漏洞，也能通过 cargo tree -p chrono --reverse 快速定位到项目中哪些库依赖到了 chrono

## pactree

Linux 包管理可视化依赖树也有个类似 cargo tree 的工具，叫 pactree

```
[w@ww runtime]$ pactree --reverse zeromq
zeromq
├─libteam
│ └─networkmanager
│   └─networkmanager-qt
│     └─plasma-nm
└─python-pyzmq
  └─python-jupyter_client
    ├─jupyter
    │ └─jupyter-nbconvert
    │   └─jupyter-notebook
    │     └─jupyter-widgetsnbextension
    │       └─python-ipywidgets
    │         └─jupyter
    ├─jupyter-notebook
    ├─jupyter_console
    │ └─jupyter
    └─python-ipykernel
      ├─jupyter
      ├─jupyter_console
      └─python-jupyter_client
```
