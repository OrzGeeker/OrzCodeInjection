# 从`App Store`获取三方ipa安装包

- Mac上通过`Apple Configurator`下载iPA
- 下载后，进行临时目录导出ipa：

```bash
$ open ~/Library/Group\ Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps/
```

- iOS中所有APP上传到APP Store后都会被加上一层保护壳， 如果我们通过一些手段下载下来得到 IPA 也无法进行任何修改和分析， 对 IPA 进行脱壳后就可以任意进行修改。对IPA进行脱壳后可以：APP重签名、APP双开、逆向分析APP、修改 HOOK APP逻辑、制作辅助APP插件、导出IPA头文件，反汇编分析 APP 等等...

- 如果你还没有掌握自已脱壳的技术，那么这个步骤可以不用进行，因为不会脱壳，即使有了App Store的ipa包也干不了什么事
- 网上有提供应用脱壳服务的，可以直接向他们获取经过脱壳的应用后再进行Hack操作, 例如：[付费脱壳服务](https://www.dumpapp.com/)
