//
//  PtraceProtect.h
//  OrzHook
//
//  Created by wangzhizhou on 2021/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PtraceProtect : NSObject

/// 简单调用系统ptrace接口，拒绝应用通debugServer被调试
+ (void)enableSimplePtraceDenyAttach;


@end

NS_ASSUME_NONNULL_END
