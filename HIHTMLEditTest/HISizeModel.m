//
//  HISizeModel.m
//  HIHTMLEditTest
//
//  Created by HIChen on 16/7/22.
//  Copyright © 2016年 风聆小镇工作室. All rights reserved.
//

#import "HISizeModel.h"

@implementation HISizeModel
+ (instancetype)size{
    return [[HISizeModel alloc] init];
}

+ (instancetype)sizeWithWidth:(float)width height:(float)height{
    HISizeModel *size = [[HISizeModel alloc] init];
    size.width = width;
    size.height = height;
    size.rate = width / height;
    return size;
}
@end
