# 砸壳

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

## 砸壳方法

### 直接获取砸过壳的应用

1. (付费下载)https://www.dumpapp.com/
2. 
### 自己手动砸壳应用(需要有越获经验)
#### [dumpdecrypted](https://github.com/stefanesser/dumpdecrypted.git)

```bash
git clone --depth=1 https://github.com/stefanesser/dumpdecrypted.git \
cd dumpdecrypted \
make
```
#### Clutch