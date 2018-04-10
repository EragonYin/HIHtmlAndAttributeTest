//
//  HINetworkTool.m
//  HIHTMLEditTest
//
//  Created by h_n on 2018/4/10.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import "HINetworkTool.h"
#import "HIDataBase.h"

@implementation HINetworkTool

/** 上传图片到资源服务器*/
+ (void)uploadImage:(UIImage *)image completed:(networkCompletedBlock)compelted {
    // 1. 这里仅仅是模拟网络请求，请结合实际运用
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 0.模拟网络传输的耗时
        sleep(1);
        
        // 1.此处将图片存储到本地，模拟上传到服务器
        NSString *url = [[HIDataBase shareInstance] saveImage:image];
    
        // 2.此处模拟服务器返回数据
        NSMutableDictionary *respone = [NSMutableDictionary dictionary];
        [respone setValue:url forKey:@"url"];
        [respone setValue:@(0) forKey:@"ret_code"];
        
        // 3.网络请求回调
        dispatch_async(dispatch_get_main_queue(), ^{
            compelted([respone valueForKey:@"url"], 0);
        });
    });
}

/** 提交文章到应用服务器*/
+ (void)uploadContent:(HIContentModel *)content completed:(networkCompletedBlock)compelted {
    // 1. 这里仅仅是模拟网络请求，请结合实际运用
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 0.模拟网络传输的耗时
        sleep(1);
        
        // 1.此处将文章存储到本地plist，模拟上传到服务器
        [[HIDataBase shareInstance] saveContent:content];
        
        // 2.此处模拟服务器返回数据
        NSMutableDictionary *respone = [NSMutableDictionary dictionary];
        [respone setValue:@"上传成功" forKey:@"message"];
        [respone setValue:@(0) forKey:@"ret_code"];
        
        // 3.网络请求回调
        dispatch_async(dispatch_get_main_queue(), ^{
            compelted(respone, 0);
        });
    });
    
}

@end
