//
//  HIObject.h
//  HIHTMLEditTest
//
//  Created by h_n on 2018/4/10.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HIObject : NSObject

@end

@interface HIContentModel : HIObject

+ (instancetype)model:(NSString *)content imageUrls:(NSArray *)imageUrls;

/** 文章纯文本*/
@property (nonatomic, strong) NSString *content;
/** 图片资源的url数组*/
@property (nonatomic, strong) NSArray *imageUrls;

@end
