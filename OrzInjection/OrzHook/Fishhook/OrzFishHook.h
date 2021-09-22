//
//  OrzFishHook.h
//  OrzHook
//
//  Created by wangzhizhou on 2021/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OrzFishHook : NSObject
+ (void)hookPtraceSystemCall;
@end

NS_ASSUME_NONNULL_END
