//
//  OrzFishHook.m
//  OrzHook
//
//  Created by wangzhizhou on 2021/9/19.
//

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
