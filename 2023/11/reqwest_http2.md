# [reqwest http2 踩坑](/2023/11/reqwest_http2.md)

hyper 默认支持 http2 23年了大多数server端也是支持h2

default-tls 不支持 http2 会报错 `hyper::Error(Http2, Error { kind: GoAway(b"", FRAME_SIZE_ERROR, Library) })`

建议 default-features=false 换成 "rustls-tls"

> assert_eq!(rsp.version(), reqwest::Version::HTTP_2);

reqwest 一点不好的设计是默认的 feature 没有开启 deflate/gzip 压缩

最后，reqwest 虽然支持 http3 但是是一个 unstable feature 很多主流网站都没支持 h3
