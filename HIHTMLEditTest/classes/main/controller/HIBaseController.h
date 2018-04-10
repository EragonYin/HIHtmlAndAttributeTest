//
//  HIBaseController.h
//  HIHTMLEditTest
//
//  Created by 陈汉楠 on 09/04/2018.
//  Copyright © 2018 chenhannan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HI_SCREEN_W [[UIScreen mainScreen] bounds].size.width
#define HI_SCREEN_H [[UIScreen mainScreen] bounds].size.height
#define HI_STATUBAR_H [UIApplication sharedApplication].statusBarFrame.size.height
#define HI_NAVIGATIONBAR_H (HI_STATUBAR_H + 44)

@interface HIBaseController : UIViewController

@end
