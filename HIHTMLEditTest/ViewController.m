//
//  ViewController.m
//  HIHTMLEditTest
//
//  Created by HIChen on 16/7/22.
//  Copyright © 2016年 风聆小镇工作室. All rights reserved.
//

#import "ViewController.h"
#import "HISizeModel.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define MARGIN 20.0

@interface ViewController ()<UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/** 编辑器*/
@property (nonatomic, weak) UITextView *textView;

/**
 * 照片数组 ->用于管理
 * 1. 上传到服务器时需要
 * 2. 添加新的照片时需要
 * 3. 删除已在文中的照片时需要
 */
@property (nonatomic, strong) NSMutableArray  *photos;

/** 
 * range数组 －>编辑时记录图片range
 * 1. 添加图片时，要记录该图片的range
 * 2. 删除图片时，通过range与该数组判断得出删除的是哪张照片
 */
@property (nonatomic, strong) NSMutableArray *ranges;


#pragma mark - if need like 知乎
/** 图片的size数组*/
@property (nonatomic, strong) NSArray *imageSizeArray;
/** 所有图片key数组*/
@property (nonatomic, strong) NSArray *imageKeyArray;
/** 标准图片的字典*/
@property (nonatomic, strong) NSDictionary *b_imageDictionary;
/** 原始图片等字典*/
@property (nonatomic, strong) NSDictionary *r_imageDictionary;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(addSomePhotos)];
    
    //创建textView；
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(MARGIN * 0.5, 74, SCREEN_WIDTH-MARGIN, SCREEN_HEIGHT - 300)];
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.delegate = self;
    textView.allowsEditingTextAttributes = YES;
    [textView becomeFirstResponder];
    [self.view addSubview:textView];
    self.textView = textView;
    
    //取富文本
    NSString *path = [[NSBundle mainBundle]pathForResource:@"HTML" ofType:@"plist"];
    NSDictionary *HTMLDict = [NSDictionary dictionaryWithContentsOfFile:path];
//    NSString *htmlString = [HTMLDict valueForKey:@"HTML"];
    NSString *htmlString = [HTMLDict valueForKey:@"TESTHTML"];
    NSString *textString = [HTMLDict valueForKey:@"TESTSTRING"];
    
    // 取出每张图片的size
    self.imageSizeArray = [self getImageSizeWithHTML:htmlString];
    
    // 取出每张图片的下载地址
    NSArray *imageUrls = [self getImageUrlsWithHTML:htmlString];
    
    // 区分普通图和原图
    [self formatterImageQualityWithImages:imageUrls];
    
    //将富文本赋值给textView
//    textView.attributedText = [self htmlAttributeStringByHtmlString:htmlString];
    
//    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//    attachment.image = ;
//    attachment.bounds = ;
//    [NSAttributedString attributedStringWithAttachment:attachment];
}

/** 打开相册添加照片*/
- (void)addSomePhotos{
    NSLog(@"打开相册");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - commonly used
/** 统计文本中所有图片资源标志的range*/
- (NSArray *)rangeOfSubString:(NSString *)subStr inString:(NSString *)string {
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString *string1 = [string stringByAppendingString:subStr];
    NSString *temp;
    for (int i = 0; i < string.length; i ++) {
        temp = [string1 substringWithRange:NSMakeRange(i, subStr.length)];
        if ([temp isEqualToString:subStr]) {
            NSRange range = {i,subStr.length};
            [rangeArray addObject:NSStringFromRange(range)];
        }
    }
    return rangeArray;
}

/** 将超文本格式化为富文本*/
- (NSAttributedString *)htmlAttributeStringByHtmlString:(NSString *)htmlString{
    NSAttributedString *attributeString;
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *importParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                   NSCharacterEncodingDocumentAttribute:[NSNumber numberWithInt:NSUTF8StringEncoding]};
    NSError *error = nil;
    attributeString = [[NSAttributedString alloc] initWithData:htmlData options:importParams documentAttributes:NULL error:&error];
    return attributeString;
}

/** 将富文本格式化为超文本*/
- (NSString *)htmlStringByHtmlAttributeString:(NSAttributedString *)htmlAttributeString{
    NSString *htmlString;
    NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                   NSCharacterEncodingDocumentAttribute:[NSNumber numberWithInt:NSUTF8StringEncoding]};
    
    NSData *htmlData = [htmlAttributeString dataFromRange:NSMakeRange(0, htmlAttributeString.length) documentAttributes:exportParams error:nil];
    htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    return htmlString;
}

#pragma mark - If need like 知乎
/** 从超文本内容中取出每张图片的size*/
- (NSArray *)getImageSizeWithHTML:(NSString *)htmlString{
    // 超文本图片资源开始的标志 <img
    NSString *startSymbol = @"<img";
    // 图片资源宽度开始的标志 data-rawwidth=
    NSString *widthSymbol = @"data-rawwidth=";
    // 图片资源高度开始的标志  data-rawheight=
    NSString *heihgtSymbol = @"data-rawheight=";
    // 图片资源链接开始的标志 src
    NSString *srcSymbol = @"src";
    
    // 开始裁剪
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *sizeUrls = [htmlString componentsSeparatedByString:startSymbol];
    for (NSString *string in sizeUrls) {
        if (![string containsString:srcSymbol]) {
            continue;
        }
        NSRange widthRange = [string rangeOfString:widthSymbol];
        NSRange heightRange = [string rangeOfString:heihgtSymbol];
        NSRange srcRange = [string rangeOfString:srcSymbol];
        NSString *widthString = [string substringWithRange:NSMakeRange(widthRange.location, heightRange.location - widthRange.location)];
        NSString *heightString = [string substringWithRange:NSMakeRange(heightRange.location, srcRange.location - heightRange.location)];
        HISizeModel *size = [HISizeModel sizeWithWidth:[self stringToFloat:widthString] height:[self stringToFloat:heightString]];
        [array addObject:size];
    }
    return [array copy];
}

/** 从超文本内容中取出每张图片的下载地址*/
- (NSArray *)getImageUrlsWithHTML:(NSString *)htmlString{
    // 定义标识，从超文本重裁剪出图片地址
    NSString *startSymbol = @"http";
    NSString *endSymbol = @".jpg";
    
    // 开始裁剪
    NSMutableString *rangeOfStirng = [NSMutableString stringWithString: htmlString];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while ([rangeOfStirng containsString:startSymbol]) {
        NSRange startRange = [rangeOfStirng rangeOfString:startSymbol];
        NSRange endRange = [rangeOfStirng rangeOfString:endSymbol];
        NSRange urlRange = NSMakeRange(startRange.location, endRange.location - startRange.location + endRange.length);
        NSString *url = [rangeOfStirng substringWithRange:urlRange];
        [array addObject:url];
        [rangeOfStirng deleteCharactersInRange:urlRange];
    }
    
    return [array copy];
}

/** 将所有图片的质量区分开并序列好*/
- (void)formatterImageQualityWithImages:(NSArray *)images{
    // 标准图片的标志 _b
    NSString *_bSymbol = @"_b";
    // 原始图片的标志 _r
    NSString *_rSymbol = @"_r";
    
    NSMutableArray *imageKeys = [NSMutableArray array];
    NSMutableDictionary *b_imageUrls = [NSMutableDictionary dictionary];
    NSMutableDictionary *r_imageUrls = [NSMutableDictionary dictionary];
    for (NSString *imageUrl in images) {
        if ([imageUrl containsString:_bSymbol]) {
            NSRange range = [imageUrl rangeOfString:_bSymbol];
            NSString *key = [imageUrl substringToIndex:range.location];
            
            /**
             * 数组中没有标准图片的key，有三种情况，无论哪种，都需要将新的key存进数组
             * 1. 没有标准图片地址
             * 2. 没有原始图片地址
             * 3. 新的图片地址
             */
            if (![imageKeys containsObject:key]) {
                [imageKeys addObject:key];
            }
            [b_imageUrls setValue:imageUrl forKey:key];
        }else{
            NSRange range = [imageUrl rangeOfString:_rSymbol];
            NSString *key = [imageUrl substringToIndex:range.location];
            
            // 理由同上
            if (![imageKeys containsObject:key]) {
                [imageKeys addObject:key];
            }
            [r_imageUrls setValue:imageUrl forKey:key];
        }
    }
    self.imageKeyArray = [imageKeys copy];
    self.b_imageDictionary = [b_imageUrls copy];
    self.r_imageDictionary = [r_imageUrls copy];
}

/** 将字符串中包含的数字转为float: example "1234" -> 1234.00*/
- (float)stringToFloat:(NSString *)string{
    float size;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    [scanner scanFloat:&size];
    return size;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.textView becomeFirstResponder];
    
    // 1.取出选中的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self.photos addObject:image];
    NSRange range = NSMakeRange(self.textView.selectedRange.location, 4);
    [self.ranges addObject:NSStringFromRange(range)];
    
    NSMutableAttributedString *mutableAttr = [self.textView.attributedText mutableCopy];
    [mutableAttr insertAttributedString:[[NSAttributedString alloc] initWithString:@"[图片]"] atIndex:range.location];
    
    // 2. 将图片标志"[图片]"替换为图片并进行显示
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = image;
    CGFloat imageRate = image.size.width / image.size.height;
    attach.bounds = CGRectMake(0, 0, SCREEN_WIDTH - MARGIN * 1.5, SCREEN_WIDTH - MARGIN * 1.5 / imageRate);
    NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:attach];
    [mutableAttr replaceCharactersInRange:range withAttributedString:imageAttr];
    self.textView.attributedText = mutableAttr;
    
    NSLog(@"imagePickerController:");
    NSLog(@"text:%@",self.textView.text);
    NSLog(@"attribute%@",self.textView.attributedText);
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
//    NSLog(@"%@",[self htmlStringByHtmlAttributeString:textView.attributedText]);
//    NSLog(@"\n\n---------------------------\n\n");
//    NSLog(@"%@",textView.text);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"location:%d,length:%d",(int)range.location, (int)range.length);
    NSLog(@"%@",textView.text);
    NSLog(@"%@",textView.attributedText);
    
    return YES;
}

#pragma mark - getter
- (NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

- (NSMutableArray *)ranges{
    if (!_ranges) {
        _ranges = [NSMutableArray array];
    }
    return _ranges;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
