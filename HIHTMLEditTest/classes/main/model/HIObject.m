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

static NSString *key_body = @"body";
static NSString *key_imageUrls = @"imageUrls";


@implementation HIContentModel

+ (instancetype)model:(NSString *)content imageUrls:(NSArray *)imageUrls {
    HIContentModel *model   = [[HIContentModel alloc] init];
    model.body           = content;
    model.imageUrls         = imageUrls;
    return model;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    HIContentModel *model   = [[HIContentModel alloc] init];
    model.body           = [dictionary valueForKey:key_body];
    model.imageUrls         = [dictionary valueForKey:key_imageUrls];
    return model;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.body forKey:key_body];
    [dict setValue:self.imageUrls forKey:key_imageUrls];
    return dict;
}

@end

