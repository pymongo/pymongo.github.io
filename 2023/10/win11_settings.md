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
