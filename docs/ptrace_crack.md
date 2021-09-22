# ptrace防护与破解

## 防护

- 主工程加入ptrace头文件，ptrace是系统级函数，只要知道方法调用格式，就可以调用。
- 获取ptrace头文件，并加入主工程中，进行方法调用，如下：

```objc
#import "OrzPtraceProtect.h"
#import "PtraceHeader.h"

@implementation OrzPtraceProtect
+ (void)enableSimplePtraceDenyAttach {
    ptrace(PT_DENY_ATTACH, 0, 0, 0);
}
@end
```

可以防止当前应用被调试


## 破解

简单的调用ptrace来进行防护是很容易被破解的，由于fishhook可以hook C语言函数，所以直接用fishhook将ptrace方法绕过就可以破解

```objc
#import "OrzFishHook.h"
#import "PtraceHeader.h"
#import "fishhook.h"

static int (*ptrace_origin)(int _request, pid_t _pid, caddr_t _addr, int _data);

@implementation OrzFishHook
+ (void)hookPtraceSystemCall {
    
    struct rebinding ptraceRebinding;
    ptraceRebinding.name = "ptrace";
    ptraceRebinding.replaced = (void *)&ptrace_origin;
    ptraceRebinding.replacement = (void *)&ptrace_replace;
    
    struct rebinding rebindings[] = { ptraceRebinding };
    rebind_symbols(rebindings, sizeof(rebindings) / sizeof(rebindings[0]));
}

int ptrace_replace(int _request, pid_t _pid, caddr_t _addr, int _data) {
    if(_request == PT_DENY_ATTACH) {
        return 0;
    }
    else {
        return ptrace_origin(_request, _pid, _addr, _data);
    }
}
@end
```

- [fishhook](https://github.com/facebook/fishhook.git)：可以hook C语言函数，如果应用使用ptrace防护，可以通过注入fishhook进行破解, 把fishhook.c/fishhook.h添加到OrzHook里而
