//
//  HIMainController.h
//  HIHTMLEditTest
//
//  Created by HIChen on 16/7/22.
//  Copyright © 2016年 chenhannan. All rights reserved.
//

#import "HIBaseController.h"

@interface HIMainItem : NSObject

+ (instancetype)item:(void(^)(HIMainItem *item))completed;

/* title*/
@property (nonatomic, strong) NSString *title;
/* detail*/
@property (nonatomic, strong) NSString *detail;
/* class*/
@property (nonatomic, assign) Class vcClass;

@end

@interface HIMainController : HIBaseController

@end

