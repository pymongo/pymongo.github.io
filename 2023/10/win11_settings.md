# [win11 初始化和设置](/2023/10/win11_settings.md)

只挑重点讲，配置一个办公用 win11 系统的最低定制化

激活工具(22h2版win11用3行cmd激活不管用了): github.com/zbezj/HEU_KMS_Activator

Store
- Visual Studio Code
- Ubuntu 20.04 # wsl2

Settings
- Personalization.recommendation = false
- Privacy.search.suggest = false
- turn off virtual memory

Terminal
- scoop install 7zip python
- default use 基佬紫

shell:startup
- v2ray/clash/lantern
- keys.ahk

## 不同设备编译速度测试

mdbook v0.4.35 release build

|product|cpu|time cost|
|---|---|---|
|magicbookpro2020-ryzen|4600H|61s|
|company's desktop|12600k|23.59s|
|小新pro16 IRH8|13900H|22.1s|

rust 1.75 solana v1.18.9, do not consider ld/mold linker performance

> cargo clean && cargo c --bin solana-keygen

|cpu|os|time cost|
|---|---|---|
|13400F|ubuntu20|21.58s|
|13900H|ubuntu20|17.44s|
|5900X|manjaro|16.88s|
|5900X|ubuntu20(server)|14.79s|

mold version 2.30

> cargo clean && cargo b --bin solana-keygen

|cpu|os|time cost|
|---|---|---|
|13900H|ubuntu20 mold2.30|27.99s|
|5900X|manjaro mold2.4|23.13s|
|5900X|ubuntu20 mold2.30|19.85s|
