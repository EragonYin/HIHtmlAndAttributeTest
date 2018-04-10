//
//  HIObject.m
//  HIHTMLEditTest
//
//  Created by h_n on 2018/4/10.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import "HIObject.h"

@implementation HIObject

@end

@implementation HIContentModel

+ (instancetype)model:(NSString *)content imageUrls:(NSArray *)imageUrls {
    HIContentModel *model   = [[HIContentModel alloc] init];
    model.content           = content;
    model.imageUrls         = imageUrls;
    return model;
}

@end

