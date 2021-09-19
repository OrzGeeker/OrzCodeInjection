//
//  PtraceProtect.m
//  OrzHook
//
//  Created by wangzhizhou on 2021/9/19.
//

#import "PtraceProtect.h"
#import "PtraceHeader.h"

@implementation PtraceProtect
+ (void)enableSimplePtraceDenyAttach {
    ptrace(PT_DENY_ATTACH, 0, 0, 0);
}
@end
