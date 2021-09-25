//
//  OrzClang.m
//  OrzHook
//
//  Created by wangzhizhou on 2021/9/25.
//

// Clang插桩文档参考: https://clang.llvm.org/docs/SanitizerCoverage.html#tracing-pcs-with-guards
// 项目的OTHER_CFLAGS中添加: -fsanitize-coverage=trace-pc-guard 加这个标记遇到循环无法解决，需要改成: -fsanitize-coverage=func,trace-pc-guard


#import <Foundation/Foundation.h>
#import <dlfcn.h>

static NSMutableArray<NSString *> *symbols = nil;

extern "C" void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                                    uint32_t *stop) {
    static uint32_t N;  // Counter for the guards.
    if (start == stop || *start) return;  // Initialize only once.
    NSLog(@"INIT: %p %p\n", start, stop);
    for (uint32_t *x = start; x < stop; x++)
        *x = ++N;  // Guards should start from 1.
}

extern "C" void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    if (!*guard) return;  // Duplicate the guard check.
    
    void *PC = __builtin_return_address(0);
    Dl_info info;
    dladdr(PC, &info);
    NSString *symbol = [NSString stringWithUTF8String:info.dli_sname];
    if(!symbols) {
        symbols = [NSMutableArray array];
    }
    if(![symbols containsObject:symbol]) {
        [symbols addObject:symbol];
        NSLog(@"%@", symbol);
    }
}
