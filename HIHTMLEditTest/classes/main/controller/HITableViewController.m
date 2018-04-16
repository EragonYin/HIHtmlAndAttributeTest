//
//  HITableViewController.m
//  HIHTMLEditTest
//
//  Created by h_n on 2018/4/10.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import "HITableViewController.h"
#import "HIShowController.h"
#import "HINetworkTool.h"
#import "HIObject.h"

@interface HITableViewController ()<UITableViewDelegate, UITableViewDataSource>

/** tableView*/
@property (nonatomic, strong) UITableView *tableView;
/** 数据源*/
@property (nonatomic, strong) NSMutableArray *contents;

@end

@implementation HITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"文章列表";
    
    [self.view addSubview:self.tableView];
    
    // 从网络获取所有到文章
    [self getAllContents];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idf = @"contentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idf];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idf];
    }
    HIContentModel *content = [self.contents objectAtIndex:indexPath.row];
    cell.textLabel.text = content.body;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HIContentModel *content = [self.contents objectAtIndex:indexPath.row];
    HIShowController *showVC = [HIShowController controllerWithContent:content];
    [self.navigationController pushViewController:showVC animated:YES];
}


#pragma mark - network
- (void)getAllContents {
    [HINetworkTool getAllContentsWithCompleted:^(id data, int errorCode) {
        if (errorCode == 0) {
            self.contents = data;
            [self.tableView reloadData];
        } else {
            // 获取文章失败
        }
    }];
}

@end
