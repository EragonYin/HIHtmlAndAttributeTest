//
//  ViewController.m
//  HIHTMLEditTest
//
//  Created by HIChen on 16/7/22.
//  Copyright © 2016年 风聆小镇工作室. All rights reserved.
//

#import "ViewController.h"
#import "HISizeModel.h"

@interface ViewController ()<UITextViewDelegate>

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(push)];
    
    //创建textView；
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
    textView.delegate = self;
    [self.view addSubview:textView];
    
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
    textView.attributedText = [self htmlAttributeStringByHtmlString:htmlString];
    
//    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//    attachment.image =
//    attachment.bounds =
}

- (void)push{
    NSLog(@"提交到服务器");
}

/** 取出每张图片的size*/
- (NSArray *)getImageSizeWithHTML:(NSString *)htmlString{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *sizeUrls = [htmlString componentsSeparatedByString:@"<img"];
    for (NSString *string in sizeUrls) {
        if (![string containsString:@"src"]) {
            continue;
        }
        NSRange widthRange = [string rangeOfString:@"data-rawwidth="];
        NSRange heightRange = [string rangeOfString:@"data-rawheight="];
        NSRange srcRange = [string rangeOfString:@"src"];
        NSString *widthString = [string substringWithRange:NSMakeRange(widthRange.location, heightRange.location - widthRange.location)];
        NSString *heightString = [string substringWithRange:NSMakeRange(heightRange.location, srcRange.location - heightRange.location)];
        HISizeModel *size = [HISizeModel sizeWithWidth:[self stringToFloat:widthString] height:[self stringToFloat:heightString]];
        [array addObject:size];
    }
    return [array copy];
}

/** 取出每张图片的下载地址*/
- (NSArray *)getImageUrlsWithHTML:(NSString *)htmlString{
    NSMutableString *rangeOfStirng = [NSMutableString stringWithString: htmlString];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while ([rangeOfStirng containsString:@"http"]) {
        NSRange startRange = [rangeOfStirng rangeOfString:@"http"];
        NSRange endRange = [rangeOfStirng rangeOfString:@".jpg"];
        NSRange urlRange = NSMakeRange(startRange.location, endRange.location - startRange.location + endRange.length);
        NSString *url = [rangeOfStirng substringWithRange:urlRange];
        [array addObject:url];
        [rangeOfStirng deleteCharactersInRange:urlRange];
    }
    
    return [array copy];
}

/** 将每张图片等质量区分开*/
- (void)formatterImageQualityWithImages:(NSArray *)images{
    NSMutableArray *imageKeys = [NSMutableArray array];
    NSMutableDictionary *b_imageUrls = [NSMutableDictionary dictionary];
    NSMutableDictionary *r_imageUrls = [NSMutableDictionary dictionary];
    for (NSString *imageUrl in images) {
        if ([imageUrl containsString:@"_b"]) {
            NSRange range = [imageUrl rangeOfString:@"_b"];
            NSString *key = [imageUrl substringToIndex:range.location];
            if (![imageKeys containsObject:key]) {
                [imageKeys addObject:key];
            }
            [b_imageUrls setValue:imageUrl forKey:key];
        }else{
            NSRange range = [imageUrl rangeOfString:@"_r"];
            NSString *key = [imageUrl substringToIndex:range.location];
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

/** 将字符串转为float*/
- (float)stringToFloat:(NSString *)string{
    float size;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    [scanner scanFloat:&size];
    return size;
}


- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"%@",[self htmlStringByHtmlAttributeString:textView.attributedText]);
    NSLog(@"\n\n---------------------------\n\n");
    NSLog(@"%@",textView.text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
