# [Dockerfile 尽量一个 RUN](2022/01/dockerfile_use_one_run.md)

download/install/decompress/remove_cache 要放在同一个 RUN 语句内，

否则这个【镜像会膨胀两次】，layer 的原理

错误例子，etcd 的压缩包只有几十 MB 但会导致镜像变大上百 MB 也是多个 RUN 会让镜像多次膨胀所导致

```
ENV ETCD_VER v3.5.1
RUN curl -O -L https://github.com.cnpmjs.org/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz
RUN tar zxf etcd-${ETCD_VER}-linux-amd64.tar.gz
RUN rm etcd-${ETCD_VER}-linux-amd64.tar.gz
RUN mv etcd-${ETCD_VER}-linux-amd64 etcd
ENV PATH /etcd/:$PATH
```

正确例子

```
ENV ETCD_VER v3.5.1
RUN curl -O -L https://github.com.cnpmjs.org/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz && \
    tar zxf etcd-${ETCD_VER}-linux-amd64.tar.gz && \
    rm etcd-${ETCD_VER}-linux-amd64.tar.gz && \
    mv etcd-${ETCD_VER}-linux-amd64 etcd
ENV PATH /etcd/:$PATH
```

像多个 ENV 这种零大小无磁盘改动的没必要合并成一个，RUN 一旦涉及磁盘改动尽量合并成一个
