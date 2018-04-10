//
//  HIOperation.m
//  HIOperationDemo
//
//  Created by h_n on 2018/4/3.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import "HIOperation.h"

@interface HIOperation()

/** block*/
@property (nonatomic, strong) HIOperationBlock block;

@end

@implementation HIOperation {
    BOOL executing;
    BOOL finished;
}

+ (instancetype)operationWithBlokc:(HIOperationBlock)block {
    HIOperation *op = [[HIOperation alloc] init];
    op.block = block;
    return op;
}

- (void)finished {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - override

- (void)main {
    @try {
        // 必须为自定义的 operation 提供 autorelease pool，因为 operation 完成后需要销毁。
        @autoreleasepool {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.block(self);
            });
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception %@", e);
    }
}

- (void)start {
    //第一步就要检测是否被取消了，如果取消了，要实现相应的KVO
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    //如果没被取消，开始执行任务
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

/** 必须重写*/
- (BOOL)isAsynchronous {
    return YES;
}

/** 必须重写*/
- (BOOL)isExecuting {
    return executing;
}

/** 必须重写*/
- (BOOL)isFinished {
    return finished;
}
@end
