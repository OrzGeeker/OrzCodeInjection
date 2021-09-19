# ptrace防护与破解

## 防护

- 主工程加入ptrace头文件，ptrace是系统级函数，只要知道方法调用格式，就可以调用。
- 获取ptrace头文件，并加入主工程中，进行方法调用，如下：

```
```


## 破解

- [fishhook](https://github.com/facebook/fishhook.git)：可以hook C语言函数，如果应用使用ptrace防护，可以通过注入fishhook进行破解, 把fishhook.c/fishhook.h添加到OrzHook里而
