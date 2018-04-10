//
//  HINetworkTool.h
//  HIHTMLEditTest
//
//  Created by h_n on 2018/4/10.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^networkCompletedBlock)(id data, int errorCode);

@interface HINetworkTool : NSObject

/** 上传图片到资源服务器*/
+ (void)uploadImage:(UIImage *)image completed:(networkCompletedBlock)compelted;

/** 提交文章到应用服务器*/
+ (void)uploadContent:(NSDictionary *)content completed:(networkCompletedBlock)compelted;

@end
