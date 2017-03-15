//
//  TextExpressionView.m
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/15.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "TextExpressionView.h"
#import "NSMutableAttributedString+ExpressionImage.h"
#import "NSMutableAttributedString+FrameRef.h"
#import "UIView+frameAdjust.h"
#import "UIImageView+AttGif.h"

@interface TextExpressionView ()

@property (nonatomic,strong)NSMutableAttributedString *attString;

@property (nonatomic,strong)NSArray<LWAttributedImage *> *expressionModelArray;

@property (nonatomic,strong)NSMutableArray<UIImageView *> *expressionViewArray;

@property (nonatomic, assign) CTFrameRef frameRef;

@end

@implementation TextExpressionView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.expressionSize = CGSizeZero;
        self.font = [UIFont systemFontOfSize:16];
        self.numberOfLines = 0;
    }
    return self;
}

-(void)setText:(NSAttributedString *)text
{
    _text = text;
    self.attString = [text mutableCopy];
    
    self.expressionModelArray = [self.attString getAttImageWithImageSize:self.expressionSize referenceFont:self.font];
    
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // 1.获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 2.翻转坐标系
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, rect.size.height), 1.f, -1.f);
    CGContextConcatCTM(context, transform);
    
    // 3.获取CTFrameRef
    self.frameRef = [self.attString prepareFrameRefWithRect:rect];
    
//    // 4.绘制高亮背景颜色
//    [self drawHighlightedColor];
    
    // 5.一行一行的绘制文字
    [self frameLineDraw];

    // 6.绘制图片
    [self drawImages];
}


#pragma mark draw__sub
/**
 * 绘制文字
 */
- (void)frameLineDraw
{
    // 0.如果self.frameRef为空，直接返回
    if (!self.frameRef) return;
    
    // 1.计算当前需要绘制文字的行数
    // 1.1获取lineRef的数组
    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    // 1.2获取lineRef的个数
    CFIndex lineCount = CFArrayGetCount(lines);
    // 1.3计算需要展示的行数
    NSUInteger numberOfLines = self.numberOfLines != 0 ? MIN(lineCount, self.numberOfLines) : lineCount;
    
    //  2.获取每一行的起始位置数组
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, numberOfLines), lineOrigins);
    
    // 3.遍历需要显示文字的行数，并绘制每一行的现实内容
    for (CFIndex idx = 0; idx < numberOfLines; idx ++) {
        // 3.0获取图形上下文和每一行对应的lineRef
        CGContextRef context = UIGraphicsGetCurrentContext();
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, idx);
        
        // 3.1设置文本的起始绘制位置
        CGContextSetTextPosition(context, lineOrigins[idx].x, lineOrigins[idx].y);
        
        // 3.2设置是否需要完整绘制一行文字的标记
        BOOL shouldDrawLine = YES;
        
        // 3.3处理最后一行
        if (idx == numberOfLines - 1 && self.numberOfLines != 0) {
            // 3.3.1.处理最后一行的文字绘制
            [self drawLastLineWithLineRef:lineRef];
            
            // 3.3.2标记不用完整的去绘制一行文字
            shouldDrawLine = NO;
        }
        
        // 3.4绘制完整的一行文字
        if (shouldDrawLine) {
            CTLineDraw(lineRef, context);
        }
    }
}

/**
 * 绘制最后一行文字
 */
- (void)drawLastLineWithLineRef:(CTLineRef)lineRef
{
    // 1.获取当前行在文本中的范围
    CFRange lastLineRange = CTLineGetStringRange(lineRef);
    // 2.比较最后显示行的最后一个文字的长度和文本的总长度
    // -> 最后一个文字的长度 < 文本的总长度
    // -> 用户设置了限制文本长度，单独处理最后一个的最后一个字符即可
    if (lastLineRange.location + lastLineRange.length < (CFIndex)self.attString.length) {
        // 2.1获取最后一行的属性字符串
        NSMutableAttributedString *truncationString = [[self.attString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
        
        if (lastLineRange.length > 0) {
            // 2.2获取最后一个字符
            unichar lastCharacter = [[truncationString string] characterAtIndex:lastLineRange.length - 1];
            
            // 2.3判断Unicode字符集是否包含lastCharacter
            if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:lastCharacter]) {
                // 2.4.1安全的删除truncationString中最后一个字符
                [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
            }
        }
        
        // 2.5获取截断属性的位置
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
        
        // 2.6获取需要截断的属性
        NSDictionary *tokenAttributes = [self.attString attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
        
        //  2.7初始化一个带属性字符串 -> “...”
        static NSString* const kEllipsesCharacter = @"\u2026";
        NSMutableAttributedString *tokenString = [[NSMutableAttributedString alloc] initWithString:kEllipsesCharacter attributes:tokenAttributes];
        
        // 2.8把“...”添加到最后一行尾部
        [truncationString appendAttributedString:tokenString];
        
        // 2.9处理最后一行的lineRef
        CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
        CTLineTruncationType truncationType = kCTLineTruncationEnd;
        
        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)tokenString);
        
        CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, self.frame.size.width, truncationType, truncationToken);
        
        if (!truncatedLine) {
            truncatedLine = CFRetain(truncationToken);
        }
        CFRelease(truncationLine);
        CFRelease(truncationToken);
        
        // 绘制本行文字
        CGContextRef context = UIGraphicsGetCurrentContext();
        CTLineDraw(truncatedLine, context);
        CFRelease(truncatedLine);
    }else{
        CGContextRef context = UIGraphicsGetCurrentContext();
        CTLineDraw(lineRef, context);
    }
}

/**
 * 绘制图片
 */
- (void)drawImages
{
    // 如果_frameRef不存在，直接退出
    if (!self.frameRef) return;
    
    // 移除以前的图片视图
    [self.expressionViewArray enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.expressionViewArray = [[NSMutableArray alloc]init];
    
    // 1.获取需要展示的行数
    // 1.1获取lineRef的数组
    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    // 1.2获取lineRef的个数
    CFIndex lineCount = CFArrayGetCount(lines);
    // 1.3计算需要展示的行树
    NSUInteger numberOfLines = self.numberOfLines != 0 ? MIN(lineCount, self.numberOfLines) : lineCount;
    
    //  2.获取每一行的起始位置数组
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, numberOfLines), lineOrigins);
    
    // 3.循环遍历每一组中是否包含link
    for (CFIndex idx = 0; idx < numberOfLines; idx ++) {
        // 3.1寻找图片占位符的准备工作
        // 3.1.1获取idx对应行的lineRef
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, idx);
        // 3.1.2获取当前lineRef中的runRef数组
        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        // 3.1.3获取当前lineRef中的runRef的个数
        CFIndex runCount = CFArrayGetCount(runs);
        // 3.1.4获取每一行对应的位置
        CGPoint lineOrigin = lineOrigins[idx];
        
        // 3.2遍历lineRef中的runRef,查找图片占位符
        for (CFIndex idx = 0; idx < runCount; idx ++) {
            // 3.2.1获取lineRef中对应的RunRef
            CTRunRef runRef = CFArrayGetValueAtIndex(runs, idx);
            // 3.2.2获取对应runRef的属性字典
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(runRef);
            // 3.2.3获取对应runRef的CTRunDelegateRef
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            // 3.2.3如果不存在，直接退出本次遍历
            // ->证明不是图片，因为我们只给图片设置了CTRunDelegateRef
            if (nil == delegate) continue;
            
            // －>证明图片在runRef里
            // 4.开始绘制图片
            // 4.1获取图片的数据模型
            LWAttributedImage *imageData = (LWAttributedImage *)CTRunDelegateGetRefCon(delegate);
            
            // 4.2获取需要展示图片的frame
            CGRect imageFrame = CTRunGetTypographicBoundsForImageRect(runRef, lineRef, lineOrigin, imageData);
            
            // 4.3添加图片
            if (imageData.imageType == LWImageTypeGIF) {
                // 初始化imageView
                UIImageView *imageView = [UIImageView imageViewWithGIFName:imageData.imageString frame:imageFrame];
                // 调整imageView的Y坐标
                [imageView setY:self.height - imageView.height - imageView.y];
                [self addSubview:imageView];
                [self.expressionViewArray addObject:imageView];
            }else{
                // 添加图形上下文
                CGContextRef context = UIGraphicsGetCurrentContext();
                UIImage *image = [UIImage imageNamed:imageData.imageString];
                // 绘制图片
                CGContextDrawImage(context, imageFrame, image.CGImage);
            }
        }
    }
}



#pragma mark property
-(void)setFrameRef:(CTFrameRef)frameRef
{
    if (_frameRef != frameRef) {
        if (_frameRef != nil) {
            CFRelease(_frameRef);
        }
        CFRetain(frameRef);
        _frameRef = frameRef;
    }
}

@end
