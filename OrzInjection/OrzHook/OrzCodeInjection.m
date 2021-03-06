//
//  OrzCodeInjection.m
//  OrzHook
//
//  Created by wangzhizhou on 2021/9/13.
//

#import "OrzCodeInjection.h"
#import <objc/runtime.h>
#import "OrzPtraceProtect.h"
#import "OrzFishHook.h"

@implementation OrzCodeInjection
+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showFLEX];
    });
    
    // hook ptrace系统调用，绕过ptrace防护
    [OrzFishHook hookPtraceSystemCall];
    
    // 拒绝进程被调试器附着
    [OrzPtraceProtect enableSimplePtraceDenyAttach];
}

+ (void)showFLEX {
    // 执行: [FLEXManager sharedManager]
    Class FLEX = objc_getClass("FLEXManager");
    SEL selector1 = NSSelectorFromString(@"sharedManager");
    IMP imp1 = [FLEX methodForSelector:selector1];
    id (*func1)(id, SEL) = (void *)imp1;
    if(func1 == NULL) {
        return;
    }
    id sharedInstance = func1(FLEX, selector1);
    
    // 执行: [[FLEXManager sharedManager] showExplorer]
    SEL selector2 = NSSelectorFromString(@"showExplorer");
    IMP imp2 = [sharedInstance methodForSelector:selector2];
    void (*func2)(id, SEL) = (void *)imp2;
    func2(sharedInstance, selector2);
}
@end
