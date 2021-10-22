//
//  OrzCrash.h
//  OrzHook
//
//  Created by wangzhizhou on 2021/10/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OrzCrash : NSObject
+ (void)installUncaughtExceptionHandler;
@end

NS_ASSUME_NONNULL_END
