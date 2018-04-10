//
//  HIOperation.h
//  HIOperationDemo
//
//  Created by h_n on 2018/4/3.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HIOperation;

typedef void(^HIOperationBlock)(HIOperation *operation);

@interface HIOperation : NSOperation

+ (instancetype)operationWithBlokc:(HIOperationBlock)block;

/** 标记完成*/
- (void)finished;

@end
