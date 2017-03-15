//
//  NSAttributedString+ExpressionImage.m
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/14.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "NSMutableAttributedString+ExpressionImage.h"
#import "UIImageView+AttGif.h"
#define imageInset UIEdgeInsetsMake(0.f, 1.f, 0.f, 1.f)

static NSString *kImagePattern = @"\\[.*?\\]";


@implementation NSMutableAttributedString (ExpressionImage)


-(NSArray<LWAttributedImage *> *)getAttImageWithImageSize:(CGSize)imageSize referenceFont:(UIFont *)referenceFont
{
    // 1.用来保存图片对象的数组
    NSMutableArray *arrM = [NSMutableArray array];
    
    // 2.正则处理[\]
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kImagePattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    // 3.遍历获取到的图片
    [regex enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        // 3.0获取正则查找出来的内容
        NSString *resultString = [self.string substringWithRange:result.range];
        // 3.1初始化并设置图片对象属性
        LWAttributedImage *imageData = [[LWAttributedImage alloc]init];
        // 3.1.1获取图片名字
        NSString *imageName = [[resultString substringFromIndex:2] substringToIndex:resultString.length - 3];
        // 3.1.2设置图片名字
        imageData.imageString = imageName;
        // 8.设置图片在属性字符串中的位置
        imageData.imageRange = result.range;
        
        // 3.2添加进入数组
        [arrM addObject:imageData];
    }];
    
    // 4.遍历图片数组，处理图片相关内容
    // 4.0获取图片所在位置的fontRef
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)referenceFont.fontName, referenceFont.pointSize, NULL);
    for (LWAttributedImage *imageData in arrM) {
        // 4.1获取图片
        UIImage *image = [UIImage imageNamed:imageData.imageString];
        // 4.1.1判断图片是否存在，如果不存在退出本次循环，并从数组中移除数据
        if (!image) {
            // 4.1.2移除数据
            [arrM removeObject:imageData];
            // 4.1.3退出循环
            continue;
        }
        
        // 4.2设置图片大小
        // 4.2.1当传入的imageSize为0的时候，图片大小跟字体一样
        if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
            imageData.imageSize = CGSizeMake(referenceFont.pointSize, referenceFont.pointSize);
        }
        // 4.2.2当传入的imageSize不为0的时候，图片大小设置为imageSize
        else {
            imageData.imageSize = imageSize;
        }
        
        // 5.设置imageData相关属性
        // 5.1设置fontRef,方便设置图片位置
        imageData.fontRef = fontRef;
        // 5.2设置图片与文字上下左右的间距
        imageData.imageInsets = imageInset;
        // 5.3设置图片类型
        imageData.imageType = [NSString contentTypeForImageName:imageData.imageString];
        
        // 6.设置图片占位AttributedString
        NSAttributedString *attSring = [NSMutableAttributedString attributedStringWithImageData:imageData];
        
        // 7.获取原始传入图片在显示内容字符串中的位置
        NSString *imageStr = [NSString stringWithFormat:@"[/%@]", imageData.imageString];
        NSRange range = [self.string rangeOfString:imageStr];
        
//        // 8.设置图片在属性字符串中的位置
//        imageData.imageRange = NSMakeRange(range.location, 0);
        
        // 9.占位图片属性字符串替换图片名
        [self replaceCharactersInRange:range withAttributedString:attSring];
    }
    
    return arrM;
}



+ (NSAttributedString *)attributedStringWithImageData:(LWAttributedImage *)imageData
{
    // 1.设置runDelegate的回调信息
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    // 2.创建CTRun回调
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(imageData));
    
    // 3.使用 0xFFFC 作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *string = [NSString stringWithCharacters:&objectReplacementChar length:1];
    
    // 4.初始化占位符空属性字符串
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    
    // 5.设置占位符空属性字符串的kCTRunDelegateAttributeName
    [attString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];
    
    // 6.释放
    CFRelease(runDelegate);
    
    return attString;
}


/**
 * 获取图片的Ascent
 * height = ascent + descent
 */
static CGFloat ascentCallback(void *ref)
{
    // 1.获取imageData
    LWAttributedImage *imageData = (__bridge LWAttributedImage *)ref;
    
    // 2.获取图片的高度
    CGFloat imageHeight = attributedImageSize(imageData).height;
    
    // 3.获取图片对应占位属性字符串的Ascent和Descent
    CGFloat fontAscent  = CTFontGetAscent(imageData.fontRef);
    CGFloat fontDescent = CTFontGetDescent(imageData.fontRef);
    
    // 4.计算基线->Ascent和Descent分割线
    CGFloat baseLine = (fontAscent + fontDescent) / 2.f - fontDescent;
    
    // 5.获得正确的Ascent
    return imageHeight / 2.f + baseLine;
}

/**
 * 获取图片的Descent
 * height = ascent + descent
 */
static CGFloat descentCallback(void *ref)
{
    // 1.获取imageData
    LWAttributedImage *imageData = (__bridge LWAttributedImage *)ref;
    
    // 2.获取图片的高度
    CGFloat imageHeight = attributedImageSize(imageData).height;
    
    // 3.获取图片对应占位属性字符串的Ascent和Descent
    CGFloat fontAscent  = CTFontGetAscent(imageData.fontRef);
    CGFloat fontDescent = CTFontGetDescent(imageData.fontRef);
    
    // 4.计算基线->Ascent和Descent分割线
    CGFloat baseLine = (fontAscent + fontDescent) / 2.f - fontDescent;
    
    // 5.获得正确的Ascent
    return imageHeight / 2.f - baseLine;
}

/**
 * 获取图片的宽度
 */
static CGFloat widthCallback(void *ref)
{
    // 1.获取imageData
    LWAttributedImage *imageData = (__bridge LWAttributedImage *)ref;
    // 2.获取图片宽度
    return attributedImageSize(imageData).width;
}

/**
 * 获取占位图片的最终大小
 */
static CGSize attributedImageSize(LWAttributedImage *imageData)
{
    CGFloat width = imageData.imageSize.width + imageData.imageInsets.left + imageData.imageInsets.right;
    CGFloat height = imageData.imageSize.height+ imageData.imageInsets.top  + imageData.imageInsets.bottom;
    return CGSizeMake(width, height);
}

@end
