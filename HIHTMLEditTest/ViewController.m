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
 * 索引数组 －>编辑时记录图片location
 * 1. 添加图片时，要记录该图片的location
 * 2. 删除图片时，通过location与该数组判断得出删除的是哪张照片
 */
@property (nonatomic, strong) NSMutableArray *locations;


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
    self.title = @"按回车模拟发送请求";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(addSomePhotos)];
    
    
    /*强势分割线*/
    /**
     * 此处模拟已经获取到数据，并且后台返回了图片url数组
     * 此处用文件模拟图片已经下载到本地
     */
    NSString *textString_2 = @"我今天很开心[图片], 因为我学会了吃饭[图片][图片]";
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        NSString *name = [NSString stringWithFormat:@"%d", i+1];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:name ofType:@"png"]];
        [images addObject:image];
    }
    self.textView.attributedText = [self replaceSymbolStringWithSymbol:@"[图片]" string:textString_2 images:images];
    
    /*强势分割线*/
    /**
     * 此处模拟已经获取到知乎数据，并进行展示
     * 因为知乎后台没有返回url数组，直接将HTML文本返回，所以必须从HTML文本中获取图片url
     * 此处没有进行下载图片，只是单纯的演示如何取出图片url，分类
     * 此处没有进行排版，只是单纯的进行将超文本转换为富文本进行展示
     * 此处要吐槽知乎的后台
     * 若想模拟，请参照上面。
     */
    NSDictionary *HTMLDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"HTML" ofType:@"plist"]];
    //NSString *htmlString = [HTMLDict valueForKey:@"HTML"];
    NSString *htmlString = [HTMLDict valueForKey:@"TESTHTML"];
    NSString *textString = [HTMLDict valueForKey:@"TESTSTRING"];
    // 取出每张图片的size
    self.imageSizeArray = [self getImageSizeWithHTML:htmlString];
    // 取出每张图片的下载地址
    NSArray *imageUrls = [self getImageUrlsWithHTML:htmlString];
    // 区分普通图和原图
    [self formatterImageQualityWithImages:imageUrls];
    
    // self.textView.attributedText = [self htmlAttributeStringByHtmlString:htmlString];
    
}

/** 打开相册添加照片*/
- (void)addSomePhotos{
    NSLog(@"打开相册");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

/** 发送数据到服务器*/
- (void)postToServer{
    NSLog(@"\n\n------------------");
    // 1. 发送带有图片标志的纯文本到服务器
    NSString *textString = [self textStringWithSymbol:@"[图片]" attributeString:self.textView.attributedText];
    NSLog(@"发送带有图片标志的纯文本到服务器, 纯文本内容为:%@", textString);
    
    // 2. 发送图片数据到服务器
    NSLog(@"发送图片到图片服务器....");
}

/** 
 * 将纯文本中带有图片标志的文本替换为富文本
 * symbol: 图片标志
 * string: 后台返回的纯文本
 * images: 已经保存到本地的图片 -> 网络图片先download到沙盒才能控制size
 */
- (NSAttributedString *)replaceSymbolStringWithSymbol:(NSString *)symbol string:(NSString *)string images:(NSArray *)images{
    // 取出所有图片标志的索引
    NSArray *ranges = [self rangeOfSymbolString:symbol inString:string];
    
    #warning Tips 可以先将后台返回的纯文字转成富文本再赋值给textView.attributeText, 或者先其他方式
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:string];
    
    // 只有mutable类型的富文本才能进行编辑
    NSMutableAttributedString *attributeString = [self.textView.attributedText mutableCopy];
    
    #warning Tips about size: 和后台约定好，自己算或者后台给，一般只需要比例即可，可以下载好图片后，利用图片等size计算宽高比.
    
    #warning Tips about base: 因为将图片标志替换为图片之后，attributeString的长度回发生变化，所以需要用base进行修正
    
    NSUInteger base = 0;
    for(int i=0; i < ranges.count; i++){
        NSRange range = NSRangeFromString(ranges[i]);
        UIImage *image = images[i];
        CGFloat rate = image.size.width / image.size.height;
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.image = image;
        attach.bounds = CGRectMake(10, 10, self.textView.frame.size.width - MARGIN, self.textView.frame.size.width - MARGIN / rate);
        [attributeString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        base -= (symbol.length - 1);
    }
    
    return attributeString;
}

/** 将图片插入到富文本中*/
- (void)setAttributeStringWithImage:(UIImage *)image{
    // 1. 保存图片与图片的location
    [self.photos addObject:image];
    [self.locations addObject:@(self.textView.selectedRange.location)];
    
    // 2. 将图片插入到富文本中
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = image;
    CGFloat imageRate = image.size.width / image.size.height;
    attach.bounds = CGRectMake(10, 10, SCREEN_WIDTH - MARGIN * 4, SCREEN_WIDTH - MARGIN * 4 / imageRate);
    NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:attach];
    //    [mutableAttr replaceCharactersInRange:range withAttributedString:imageAttr];
    NSMutableAttributedString *mutableAttr = [self.textView.attributedText mutableCopy];
    [mutableAttr insertAttributedString:imageAttr atIndex:self.textView.selectedRange.location];
    self.textView.attributedText = mutableAttr;
}

/** 将富文本转换为带有图片标志的纯文本*/
- (NSString *)textStringWithSymbol:(NSString *)symbol attributeString:(NSAttributedString *)attributeString{
    //最终纯文本
    NSMutableString *textString = [NSMutableString stringWithString:attributeString.string];
    
    //替换下标的偏移量
    __block NSUInteger base = 0;
    
    //遍历
    [attributeString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributeString.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                      //检查类型是否是自定义NSTextAttachment类
                      if (value && [value isKindOfClass:[NSTextAttachment class]]) {
                          //替换
                          [textString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:symbol];
                          //增加偏移量
                          base += (symbol.length - 1);
                      }
                  }];
    
    return textString;
}

#pragma mark - commonly used
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
    
    [self setAttributeStringWithImage:(UIImage *)image];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"location:%d,length:%d",(int)range.location, (int)range.length);
    
    // 模拟点击回车发送资料到服务器
    if ([text isEqualToString:@"\n"]) {
        // 提交到服务器
        [self postToServer];
    }
    
    return YES;
}

#pragma mark - getter
- (UITextView *)textView{
    if (!_textView) {
        //创建textView；
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(MARGIN * 0.5, 74, SCREEN_WIDTH-MARGIN, SCREEN_HEIGHT - 300)];
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textView.delegate = self;
        textView.allowsEditingTextAttributes = YES;
        [textView becomeFirstResponder];
        [self.view addSubview:textView];
        _textView = textView;
    }
    return _textView;
}

- (NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

- (NSMutableArray *)locations{
    if (!_locations) {
        _locations = [NSMutableArray array];
    }
    return _locations;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
