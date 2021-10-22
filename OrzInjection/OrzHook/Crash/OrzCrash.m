//
//  OrzCrash.m
//  OrzHook
//
//  Created by wangzhizhou on 2021/10/17.
//

#import "OrzCrash.h"
static void exceptionHandler(NSException *exception) {
    NSLog(@"有异常, %@", exception);
}
@implementation OrzCrash
+(void)load {
    [OrzCrash installUncaughtExceptionHandler];
}
+ (void)installUncaughtExceptionHandler {
    NSSetUncaughtExceptionHandler(&exceptionHandler);
}
@end
