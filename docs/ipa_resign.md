# 重签名

有了脱过壳的ipa就可以使用本仓库提供的工程进行代码重签名后，进行代码注入和分析了。

- 工程目录下的`App-decrypted`目录下放好已经脱壳的ipa文件
- 先把工程中的`Build Phaes`中的 `App Code Sign Script`脚本的内容注释掉，在真机上把工程跑起来，验证应用后,确认新建的工程可以在真机上运行起来，再把脚本的内容取消注释，清理一下编译缓存再运行一次工程，即可把重签名后的App运行起来。
- AppCodeSign.sh脚本中进行了应用重签名的工作
- 重签名应用后，再进行代码注入后，就可以进行逆向分析了
## 相关原理
- [iOS签名技术](https://youtu.be/spn-Jhc-LPE)
- [iOS微信代码注入](https://youtu.be/BxSKoaIfln0)
- [iOS抖音代码注入](https://youtu.be/Y91RUBBbxGQ)
