//
//  HIEditController.m
//  HIHTMLEditTest
//
//  Created by 陈汉楠 on 09/04/2018.
//  Copyright © 2018 chenhannan. All rights reserved.
//

#import "HIEditController.h"

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

@end
