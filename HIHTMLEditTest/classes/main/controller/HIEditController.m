//
//  HIEditController.m
//  HIHTMLEditTest
//
//  Created by 陈汉楠 on 09/04/2018.
//  Copyright © 2018 chenhannan. All rights reserved.
//

#import "HIEditController.h"
#import "HINetworkTool.h"
#import "HIOperation.h"

@interface HIEditController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

/** textView*/
@property (nonatomic, strong) UITextView *textView;

/**
 * 保存添加的图片，用于上传到资源服务器
 */
@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation HIEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationBar];
    
    [self.view addSubview:self.textView];
}

- (void)setNavigationBar {
    self.title = @"编辑文字";
    
    UIBarButtonItem *photoItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openAlbum)];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendContent)];
    self.navigationItem.rightBarButtonItems = @[photoItem, sendItem];
}

#pragma mark - getter
- (UITextView *)textView {
    if (!_textView) {
        CGFloat margin = 10;
        _textView = [[UITextView alloc] init];
        _textView.frame = CGRectMake(margin, HI_NAVIGATIONBAR_H + margin, self.view.bounds.size.width - margin * 2, 320);
        _textView.delegate = self;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.layer.borderWidth = 1;
        _textView.layer.cornerRadius = 4;
    }
    return _textView;
}

- (NSMutableArray *)photos {
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

#pragma mark - handle action

/** 打开相册添加图片*/
- (void)openAlbum {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

/** 把内容上传到服务器*/
- (void)sendContent {
    NSLog(@"模拟发送到服务器");
    
    // 1.替换图片资源为图片标志，获取纯文本
    NSString *content = [self textStringWithSymbol:@"[图片]" attributeString:self.textView.attributedText];
    
    // 2.将图片上传到资源服务器，获取图片url
    __weak typeof(self) weakSelf = self;
    [self updataImages:self.photos completed:^(NSArray *imageUrls) {
        // 3.将纯文本和图片资源url同时上传到应用服务器
        [weakSelf uploadContent:content imageUrls:imageUrls completed:^{
            // 4.上传成功，该退出当前控制器了
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
    
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSAttributedString *attributeString = textView.attributedText;
    
    // 判断删除的是否为attachment，若是则要删除图片数组的资源
    [attributeString enumerateAttribute:NSAttachmentAttributeName inRange:range options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        //检查类型是否是自定义NSTextAttachment类
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {
            NSTextAttachment *attachment = value;
            [self.photos removeObject:attachment.image];
        }
    }];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.textView becomeFirstResponder];
    
    // 1.取出选中的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    // 2.将图片添加到文本中
    [self setAttributeStringWithImage:image];
}

#pragma mark - private
/** 将图片插入到富文本中*/
- (void)setAttributeStringWithImage:(UIImage *)image{
    // 1. 保存图片与图片的location
    [self.photos addObject:image];
    
    // 2. 将图片插入到富文本中
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = image;
    CGFloat imageRate = image.size.width / image.size.height;
    CGFloat margin = 10;
    attach.bounds = CGRectMake(0, margin, self.textView.frame.size.width - margin, (self.textView.frame.size.width - margin) / imageRate);
    NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:attach];
    NSMutableAttributedString *mutableAttr = [self.textView.attributedText mutableCopy];
    [mutableAttr insertAttributedString:imageAttr atIndex:self.textView.selectedRange.location];
    self.textView.attributedText = mutableAttr;
}

/** 将富文本转换为带有symbol图片标志的纯文本*/
- (NSString *)textStringWithSymbol:(NSString *)symbol attributeString:(NSAttributedString *)attributeString{
    NSString *string = attributeString.string;
    // 最终纯文本
    NSMutableString *textString = [NSMutableString stringWithString:string];
    // 替换下标的偏移量
    __block NSUInteger base = 0;
    
    // 遍历
    [attributeString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributeString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        // 检查类型是否是自定义NSTextAttachment类
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {
            // 替换
            [textString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:symbol];
            // 增加偏移量
            base += (symbol.length - 1);
        }
    }];
    return textString;
}

#pragma mark - 网络请求

/**
 * 传图片到资源服务器
 * images: 需要上传的图片数组
 * completed: 回调上传完成后获得去图片url数组
 */
- (void)updataImages:(NSArray *)images completed:(void(^)(NSArray *imageUrls))completed {
    // 若没有图片，直接回调完成，保证业务逻辑
    if (images == nil || images.count == 0) {
        completed(nil);
        return;
    }
    
    // 若有图片，应当有序上传到资源服务器，获得有序的图片url数组
    NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:images.count];
    
    /**
     * NSOperationQueue相当于一个线程池，将所需要执行的任务都添加进去
     * queue.maxConcurrentOperationCount设置为1保证该线程池中每次只有一个任务在执行
     * 使用自定义的 HIOperation 可以认为的控制任务的状态，保证任务是有序执行，并且是执行完成的 (NSOperation无法保证有序)
     * 添加所有需要执行的任务后，需要自己监听判断线程池的所有任务是否已经完成(可以使用累增或累加计数方式)
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    // 循环添加上传任务进队列
    for (UIImage *image in self.photos) {
        HIOperation *operation = [HIOperation operationWithBlokc:^(HIOperation *operation) {
            [HINetworkTool uploadImage:image completed:^(NSString *url, int errorCode) {
                [imageUrls addObject:url];
                [operation finished];
                if (image == images.lastObject) { // 当图片为最后一张，说明都上传完毕了
                    // 回调图片资源数组
                    completed(imageUrls);
                }
            }];
        }];
        [queue addOperation:operation];
    }
}

/** 上传文章到应用服务器*/
- (void)uploadContent:(NSString *)content imageUrls:(NSArray *)imageUrls completed:(void(^)(void))completed {
    [HINetworkTool uploadContent:[HIContentModel model:content imageUrls:imageUrls] completed:^(id data, int errorCode) {
        completed();
    }];
}

@end
