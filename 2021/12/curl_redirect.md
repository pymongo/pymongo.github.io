# [curl -L follow redirect](2021/12/curl_redirect.md)

curl 下载文件后 tar xzf 解压提示格式不对，发现下载的文件大小只有 4kb 再 cat 去看发现原来是一个重定向的 CDN 链接

curl 加上 -L 参加即可 follow redirect 如下就能看到 curl 下载的第一个文件是一个重定向的链接第二个才是真正的问

```
Step 5/40 : RUN curl -O -L https://npm.taobao.org/mirrors/node/latest-v16.x/node-v16.0.0-linux-x64.tar.gz
 ---> Running in a74ccd5469d8
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   187  100   187    0     0    816      0 --:--:-- --:--:-- --:--:--   816
100 31.7M  100 31.7M    0     0  2796k      0  0:00:11  0:00:11 --:--:-- 3424k
```
