//
//  HIMainController.m
//  HIHTMLEditTest
//
//  Created by HIChen on 16/7/22.
//  Copyright © 2016年 chenhannan. All rights reserved.
//

#import "HIMainController.h"
#import "HIEditController.h"
#import "HITableViewController.h"
#import "ViewController.h"

@implementation HIMainItem

+ (instancetype)item:(void(^)(HIMainItem *item))completed {
    HIMainItem *item = [[HIMainItem alloc] init];
    completed(item);
    return item;
}

@end

@interface HIMainController ()<UITableViewDelegate, UITableViewDataSource>

/* tableView*/
@property (nonatomic, strong) UITableView *tableView;
/* datas*/
@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation HIMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"首页";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    
    [self.view addSubview:self.tableView];
}

- (void)next{
    [self.navigationController pushViewController:[[ViewController alloc] init] animated:YES];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
        [HIMainItem item:^(HIMainItem *item) {
            item.title = @"编辑富文本";
            item.detail = @"编辑后，文文本与图片资源如何分别上传到应用服务器与图片资源服务器";
            item.vcClass = [HIEditController class];
            [_datas addObject:item];
        }];
        [HIMainItem item:^(HIMainItem *item) {
            item.title = @"展示富文本";
            item.detail = @"模拟从应用服务器获取文本及相关图片资源url，处理展示富文本";
            item.vcClass = [HITableViewController class];
            [_datas addObject:item];
        }];
        [HIMainItem item:^(HIMainItem *item) {
            item.title = @"测试";
            item.detail = @"综合使用";
            item.vcClass = [ViewController class];
            [_datas addObject:item];
        }];
    }
    return _datas;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idf = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idf];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idf];
    }
    HIMainItem *item = [self.datas objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.detail;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HIMainItem *item = [self.datas objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[[item.vcClass alloc] init] animated:YES];
}

@end
