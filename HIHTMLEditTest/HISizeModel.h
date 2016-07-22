//
//  HISizeModel.h
//  HIHTMLEditTest
//
//  Created by HIChen on 16/7/22.
//  Copyright © 2016年 风聆小镇工作室. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HISizeModel : NSObject
+ (instancetype)size;
+ (instancetype)sizeWithWidth:(float)width height:(float)height;
/** 宽度*/
@property (nonatomic, assign) float width;
/** 高度*/
@property (nonatomic, assign) float height;
/** 宽高比*/
@property (nonatomic, assign) float rate;
@end
