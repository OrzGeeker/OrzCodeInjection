//
//  OrzCodeInjection.m
//  OrzHook
//
//  Created by wangzhizhou on 2021/9/13.
//

#import "OrzCodeInjection.h"
#import <objc/runtime.h>

@implementation OrzCodeInjection
+ (void)load {
    NSLog(@"JOKER: 注入成功");
    
    Class FLEX = objc_getClass("FLEXManager");
    
    NSLog(@"JOKER: %@", FLEX);
}
@end
