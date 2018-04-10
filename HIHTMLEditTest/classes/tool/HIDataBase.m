//
//  HIDataBase.m
//  HIHTMLEditTest
//
//  Created by h_n on 2018/4/10.
//  Copyright © 2018年 chenhannan. All rights reserved.
//

#import "HIDataBase.h"

@interface HIDataBase()

/** contents path*/
@property (nonatomic, strong) NSString *contentsPath;
/** images path*/
@property (nonatomic, strong) NSString *imageFolder;

@end

@implementation HIDataBase

static HIDataBase *_instance;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[super allocWithZone:NULL] init];
        }
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [HIDataBase shareInstance] ;
}

- (instancetype)copyWithZone:(struct _NSZone *)zone {
    return [HIDataBase shareInstance] ;
}

#pragma mark -  getter

- (NSString *)contentsPath {
    if (!_contentsPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _contentsPath = [paths.firstObject stringByAppendingPathComponent:@"contents.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager isExecutableFileAtPath:_contentsPath]) {
            [fileManager createFileAtPath:_contentsPath contents:nil attributes:nil];
        }
    }
    return _contentsPath;
}

- (NSString *)imageFolder {
    if (!_imageFolder) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _imageFolder = [paths.firstObject stringByAppendingString:@"/images"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager isExecutableFileAtPath:_imageFolder]) {
            [fileManager createDirectoryAtPath:_imageFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _imageFolder;
}

#pragma mark - public

/** 获取所有文章数据*/
- (NSArray *)getContents {
    return [NSArray arrayWithContentsOfFile:self.contentsPath];
}

/** 保存一条文章*/
- (void)saveContent:(HIContentModel *)content {
    NSMutableArray *contents = [NSMutableArray arrayWithContentsOfFile:self.contentsPath];
    if (contents == nil) {
        contents = [NSMutableArray array];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:content.content forKey:@"body"];
    [dict setValue:content.imageUrls forKey:@"imageUrls"];
    [contents addObject:dict];
    BOOL result = [contents writeToFile:self.contentsPath atomically:YES];
    
    if (result) {
        NSLog(@"保存文章成功: %@", self.contentsPath);
    } else {
        NSLog(@"保存文章失败");
    }
}

/** 保存图片*/
- (NSString *)saveImage:(UIImage *)image {
    // 取个时间戳来做文件名
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *filePath = [NSString stringWithFormat:@"%@/image%lld.png", self.imageFolder, (long long)time];
    
    BOOL result = [UIImageJPEGRepresentation(image, 0.1) writeToFile:filePath atomically:YES];
    if (result) {
        NSLog(@"保存图片成功: %@", filePath);
        return filePath;
    } else {
        NSLog(@"保存图片失败");
        return nil;
    }
}


@end
