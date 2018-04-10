//
//  HIDataBase.h
//  HIHTMLEditTest
//
//  Created by h_n on 2018/4/10.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HIObject.h"

@interface HIDataBase : NSObject

/** 单例对象*/
+ (instancetype)shareInstance;


/** 获取所有文章数据*/
- (NSArray *)getContents;

/** 保存一条文章*/
- (void)saveContent:(HIContentModel *)content;

/** 保存图片*/
- (NSString *)saveImage:(UIImage *)image;

@end
