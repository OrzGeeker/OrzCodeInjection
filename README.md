# OrzCodeInjection

iOS三方应用代码注入

## 从`App Store`获取三方ipa安装包

- Mac上通过`Apple Configurator`下载iPA
- 下载后，进行临时目录导出ipa：

```bash
$ open ~/Library/Group\ Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Assets/TemporaryItems/MobileApps/
```

## 砸壳

- 一般从App Store上获取的ipa包都是经过加密的，需要先对其进行解密操作，俗称"砸壳"
- 如果确认一个ipa是否被加密

```bash
otool -l WeChat.app/WeChat | grep -B 2 crypt
```
- 如果有下面的`cryptid 1`证时这个app是经过加密的
```
cmd LC_ENCRYPTION_INFO_64
cmdsize 24
cryptoff 16384
cryptsize 192823296
cryptid 1
```

- 砸壳



## 重签名



