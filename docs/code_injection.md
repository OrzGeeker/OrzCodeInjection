# 代码注入

- [MachOView](https://github.com/gdbinit/MachOView.git)分析Mach-O文件结构，用来确认是否注入成功，拉代码自己编译一下，安装到MAC上使用,使用菜单打开应用的二进制Mach-O文件，即可显示查看
- [FLEX](https://github.com/FLEXTool/FLEX.git)iOS调试工具，生成Framework
- [LookIn](https://lookin.work/)使用`lipo -thin arm64 -output LookInServer`，提取真机版本的二进制后进行注入
- [yololib](https://github.com/KJCracks/yololib.git)注入动态库工具，拉仓库在本地编译成功后，把生成的二进制拷贝到`/usr/local/bin`目录下，就可以按照命令使用了。把FLEX.framework添加到加载命令的尾部
- 每次运行都需要先Clean再编译

## 相关资源

- [yololib手动注入](https://youtu.be/0I9hL4QlyJU)



