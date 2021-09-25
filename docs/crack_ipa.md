# 砸壳

- 从App Store上获取的ipa包都是经过加密的，需要先对其进行解密操作，俗称"砸壳"
- 如何确认一个ipa是否被加密，找到应用的二进制文件后，运行下面的命令：

```bash
otool -l WeChat.app/WeChat | grep -B 2 crypt
```
- 如果有下面的`cryptid 1`证明这个app是经过加密的
```
cmd LC_ENCRYPTION_INFO_64
cmdsize 24
cryptoff 16384
cryptsize 192823296
cryptid 1
```

- 砸壳原理：iOS应用在运行到内存中操作系统会对其进行解密，砸壳的时候就是把内存中的代码dump出来

## 砸壳方法

### 直接获取砸过壳的应用

- [付费脱壳服务](https://www.dumpapp.com/) 9元/包

### 自己手动砸壳应用(需要有越获经验)

1. 手机越狱

- 网上购买完美越狱手机(重启后依然越狱正常)
- 自已手动越狱手机：[checkra1n](https://checkra.in/)
    - 关闭锁屏密码、指纹密码、面部识别
    - 登录AppleID，并关闭手机定位查找功能
    - 自动更新系统关闭
    - 下载checkra1n.dmg安装在MacOS上，按钮指导进行越狱操作
    - iPhone进入DFU模式: 用C-L(Type-C转Lightning)线不成功，换条A-L(Type-A转Lightning)线就可以了
    - 越狱成功后，安装Cydia软件，注意不要重启手机，如果是不完美越狱，重启后Cydia无法打开
    - Cydia安装OpenSSH
    - 查看手机Wifi网络设置的IP地址, 例如: `192.168.0.107`
    - `ssh root@192.168.0.107`登录越狱手机，默认密码为: `alpine`, 安装的OpenSSH中有修改默认登录密码的方法
    - 如果不想每次输入密码，可以使用这种登录方式：`ssh-copy-id root@192.168.0.107`
    - 不想每次输入`root@192.168.0.107`这一部分，可以创建配置文件`~/.ssh/config`, 添加内容如下,并保存退出后
    ```
     Host iPhone
        HostName 192.168.0.107 
        User root 
    ```
    - 下次登录就可以使用`ssh iPhone`进行快捷登录了
    
- 手机越狱成功后，需要能够使用ssh/scp登录到设备上及文件传送

2. 越狱手机上进行砸壳

#### [dumpdecrypted](https://github.com/stefanesser/dumpdecrypted.git)

```bash
git clone --depth=1 https://github.com/stefanesser/dumpdecrypted.git \
cd dumpdecrypted \
make
```
#### [Clutch](https://github.com/KJCracks/Clutch.git)
