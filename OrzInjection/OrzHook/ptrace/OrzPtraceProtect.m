//
//  OrzPtraceProtect.m
//  OrzHook
//
//  Created by wangzhizhou on 2021/9/19.
//

#import "OrzPtraceProtect.h"
#import "PtraceHeader.h"

@implementation OrzPtraceProtect
+ (void)enableSimplePtraceDenyAttach {
    ptrace(PT_DENY_ATTACH, 0, 0, 0);
}
@end
