//
//  HIContentController.m
//  HIHTMLEditTest
//
//  Created by 陈汉楠 on 09/04/2018.
//  Copyright © 2018 chenhannan. All rights reserved.
//

#import "HIShowController.h"
#import "HIOperation.h"
#import "HINetworkTool.h"

@interface HIShowController ()

/** 文章内容*/
@property (nonatomic, strong) HIContentModel *content;
/** textView*/
@property (nonatomic, strong) UITextView *textView;

@end

@implementation HIShowController

+ (instancetype)controllerWithContent:(HIContentModel *)content {
    return [[self alloc] initWithContent:content];
}

- (instancetype)initWithContent:(HIContentModel *)content {
    if (self = [super init]) {
        self.content = content;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"文章展示";
    
    // 先展示文章
    self.textView.text = self.content.body;
    [self.view addSubview:self.textView];
    
    // 下载所有的网络图片
    [self downloadImageWithImageUrls:self.content.imageUrls completed:^(NSArray<UIImage *> *images) {
        // 图片下载完成后，替换掉标志符并展示文章
        NSAttributedString *attributeString = [self replaceSymbolStringWithSymbol:imageSymbol string:self.content.body images:images];
        self.textView.attributedText = attributeString;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        _textView.editable = NO;
        _textView.font = [UIFont systemFontOfSize:20];
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.layer.borderWidth = 1;
        _textView.layer.cornerRadius = 4;
    }
    return _textView;
}

#pragma mark - private
/**
 * 将纯文本中带有图片标志的文本替换为富文本
 * symbol: 图片标志
 * string: 后台返回的纯文本
 * images: 已经保存到本地的图片 -> 网络图片先download到沙盒才能控制size
 */
- (NSAttributedString *)replaceSymbolStringWithSymbol:(NSString *)symbol string:(NSString *)string images:(NSArray *)images {
    // 取出所有图片标志的索引
    NSArray *ranges = [self rangeOfSymbolString:symbol inString:string];
    
#warning Tips 可以先将后台返回的纯文字转成富文本再赋值给textView.attributeText, 或者先其他方式
    
    NSMutableParagraphStyle *paragraStyle = [[NSMutableParagraphStyle alloc] init];
    paragraStyle.lineSpacing = 4.0;
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName:paragraStyle,NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    
    // 只有mutable类型的富文本才能进行编辑
    NSMutableAttributedString *attributeString = [self.textView.attributedText mutableCopy];
    
#warning Tips about size: 和后台约定好，自己算或者后台给，一般只需要比例即可，可以下载好图片后，利用图片等size计算宽高比.
    
#warning Tips about base: 因为将图片标志替换为图片之后，attributeString的长度回发生变化，所以需要用base进行修正
    
    int base = 0;
    for(int i=0; i < ranges.count; i++){
        NSRange range = NSRangeFromString(ranges[i]);
        // 这里替换图片
        UIImage *image = images[i];
        CGFloat rate = image.size.width / image.size.height;
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.image = image;
        CGFloat margin = 10;
        attach.bounds = CGRectMake(0, 10, self.textView.frame.size.width - margin, (self.textView.frame.size.width - margin) / rate);
        [attributeString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        base -= (symbol.length - 1);
    }
    
    return attributeString;
}

/** 统计文本中所有图片资源标志的range*/
- (NSArray *)rangeOfSymbolString:(NSString *)symbol inString:(NSString *)string {
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString *string1 = [string stringByAppendingString:symbol];
    NSString *temp;
    for (int i = 0; i < string.length; i ++) {
        temp = [string1 substringWithRange:NSMakeRange(i, symbol.length)];
        if ([temp isEqualToString:symbol]) {
            NSRange range = {i, symbol.length};
            [rangeArray addObject:NSStringFromRange(range)];
        }
    }
    return rangeArray;
}

#pragma mark - network
/** 下载所有的网络图片*/
- (void)downloadImageWithImageUrls:(NSArray *)imageUrls completed:(void(^)(NSArray<UIImage *> *images))completed {
    NSMutableArray *images = [NSMutableArray array];
    
    /**
     * NSOperationQueue相当于一个线程池，将所需要执行的任务都添加进去
     * queue.maxConcurrentOperationCount设置为1保证该线程池中每次只有一个任务在执行
     * 使用自定义的 HIOperation 可以认为的控制任务的状态，保证任务是有序执行，并且是执行完成的 (NSOperation无法保证有序)
     * 添加所有需要执行的任务后，需要自己监听判断线程池的所有任务是否已经完成(可以使用累增或累加计数方式)
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    // 循环添加上传任务进队列
    for (NSString *url in imageUrls) { // 此处模拟将所有图片下载到本地，或者用SDWebImage将所有图片缓存
        HIOperation *op = [HIOperation operationWithBlokc:^(HIOperation *operation) {
            [HINetworkTool downloadImageWithImageUrl:url compelted:^(UIImage *image, int errorCode) {
                // 存储图片
                [images addObject:image];
                
                // 判断是否所有任务完成
                if (url == imageUrls.lastObject) { // 当是最后一个完成，说明都完成了
                    completed(images);
                }
                
                // 标记当前任务完成
                [operation finished];
            }];
        }];
        [queue addOperation:op];
    }
}

@end
