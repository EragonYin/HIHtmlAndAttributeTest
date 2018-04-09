//
//  HIMainController.m
//  HIHTMLEditTest
//
//  Created by HIChen on 16/7/22.
//  Copyright © 2016年 chenhannan. All rights reserved.
//

#import "HIMainController.h"
#import "ViewController.h"

@interface HIMainController ()

@end

@implementation HIMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"前方加载图片有点慢，等一等";
    self.view.backgroundColor = [UIColor colorWithRed:100/255.0 green:152/255.0 blue:245/255.0 alpha:1];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
}

- (void)next{
    [self.navigationController pushViewController:[[ViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
