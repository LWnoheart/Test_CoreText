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

#import "NSMutableAttributedString+Hyperlink.h"


/**
 * 绘制高亮背景圆角半径
 */
static CGFloat kRadius = 2.f;


@interface TextExpressionView ()

@property (nonatomic,strong)NSMutableAttributedString *attString;

@property (nonatomic,strong)NSArray<LWAttributedImage *> *expressionModelArray;

@property (nonatomic,strong)NSMutableArray<UIImageView *> *expressionViewArray;

@property (nonatomic,strong)NSArray<LWAttributedHyperlink *> *hyperlinkModelArray;

@property (nonatomic,strong)LWAttributedHyperlink *selectedLink;

@property (nonatomic,strong)LWAttributedImage *selectedImage;

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
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setText:(NSAttributedString *)text
{
    _text = text;
    self.attString = [text mutableCopy];
    
    self.expressionModelArray = [self.attString getAttImageWithImageSize:self.expressionSize referenceFont:self.font];
    
    self.hyperlinkModelArray = [self.attString getHyperlinkWithColor:self.hyperlinkColor font:[UIFont systemFontOfSize:12]];
    
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
    
    // 4.绘制高亮背景颜色
    [self drawHighlightedColor];
    
    // 5.一行一行的绘制文字
    [self frameLineDraw];

    // 6.绘制图片
    [self drawImages];
}

#pragma mark -
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



/**
 * 绘制高亮背景颜色
 */
- (void)drawHighlightedColor
{
    if (self.selectedLink && self.frameRef) {
        // 1.获取选中的link所在的位置
        NSRange linkRange = self.selectedLink.range;
        
        // 2.获取每一行lineRef所在的位置
        // 2.1获取lineRef的数组
        CFArrayRef lines = CTFrameGetLines(self.frameRef);
        // 2.2获取lineRef的个数
        CFIndex lineCount = CFArrayGetCount(lines);
        // 2.3获取每行LineRef所在的坐标
        CGPoint lineOrigins[lineCount];
        CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
        
        // 3.循环遍历每一组中是否包含link
        for (CFIndex idx = 0; idx < lineCount; idx ++) {
            // 3.1根据lineRef的数组获取对应行的lineRef
            CTLineRef lineRef = CFArrayGetValueAtIndex(lines, idx);
            // 3.2判断当前行(CTLineRef)中是否有包含link
            if (CTLineContainsCharactersFromStringRange(lineRef, linkRange)) continue;
            
            // 3.3获取点中link的rect
            CGRect highlightRect = CTRunGetTypographicBoundsForLinkRect(lineRef, linkRange, lineOrigins[idx]);
            
            // 3.4如果返回的highlightRect不为空，则绘制
            if (!CGRectIsEmpty(highlightRect)) {
                // 3.4.1绘制高亮背景
                [self drawBackgroundColorWithRect:highlightRect];
            }
        }
    }
}

/**
 * 绘制选中链接的高亮背景
 */
- (void)drawBackgroundColorWithRect:(CGRect)rect
{
    CGFloat pointX = rect.origin.x;
    CGFloat pointY = rect.origin.y;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    // 获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填充颜色
    [self.hyperlinkBackgroundColor setFill];
    
    // 移动到初始点
    CGContextMoveToPoint(context, pointX, pointY);
    
    // 绘制第1条线和第1个1/4圆弧，右上圆弧
    CGContextAddLineToPoint(context, pointX + width - kRadius, pointY);
    CGContextAddArc(context, pointX + width - kRadius, pointY + kRadius, kRadius, -0.5*M_PI, 0.0, 0);
    
    // 绘制第2条线和第2个1/4圆弧，右下圆弧
    CGContextAddLineToPoint(context, pointX + width, pointY + height - kRadius);
    CGContextAddArc(context, pointX + width - kRadius, pointY + height - kRadius, kRadius, 0.0, 0.5*M_PI, 0);
    
    // 绘制第3条线和第3个1/4圆弧，左下圆弧
    CGContextAddLineToPoint(context, pointX + kRadius, pointY + height);
    CGContextAddArc(context, pointX + kRadius, pointY + height - kRadius, kRadius, 0.5*M_PI, M_PI, 0);
    
    // 绘制第4条线和第4个1/4圆弧，左上圆弧
    CGContextAddLineToPoint(context, pointX, pointY + kRadius);
    CGContextAddArc(context, pointX + kRadius, pointY + kRadius, kRadius, M_PI, 1.5*M_PI, 0);
    
    // 闭合路径
    CGContextFillPath(context);
}

#pragma mark -
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

#pragma mark -
#pragma mark 触摸事件响应
// 开始触摸
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    // 1.获取手指点中的坐标
    CGPoint position = [[touches anyObject] locationInView:self];
    
    // 2.根据点中的坐标，寻找对应文字的索引
    // 2.1此处返回LWAttributedHyperlink对象，返回信息都在里面
    LWAttributedHyperlink *selectedLink = [self touchLinkWithPosition:position];
    
    // 2.2判断是否选中，选中的selectedLink != nil
    if (selectedLink) {
        // 3.1设置selectedLink为全局，方便后面使用
        self.selectedLink = selectedLink;
        // 3.2刷新
        [self setNeedsDisplay];
        
        return;
    }
    
    // 3.根据点中的坐标，寻找对应图片的索引
    // 3.1此处返回LWAttributedImage对象，返回信息都在里面
    LWAttributedImage *selectedImage = [self touchContentOffWithPosition:position];
    
    // 2.2判断是否选中，选中的selectedImage != nil
    if (selectedImage) {
        // 3.1设置selectedLink为全局，方便后面使用
        self.selectedImage = selectedImage;
    }
}

// 手指移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
//    [super touchesEnded:touches withEvent:event];
//    // 0.获取手指点中的坐标
//    CGPoint position = [[touches anyObject] locationInView:self];
//    
//    // 1.判断开始触碰的时候是否选中超文本
//    if (self.selectedLink) {
//        // 1.1获取当前手指选中的超文本
//        LWAttributedHyperlink *selectedLink = [self touchLinkWithPosition:position];
//        // 1.2如果当前选中的超文本和触碰开始时选中的超文本不一致
//        // -> 取消当前选中
//        if (selectedLink != self.selectedLink) {
//            // 1.2.1取消当前选中
//            self.selectedLink = nil;
//            // 1.2.2刷新
//            [self setNeedsDisplay];
//        }
//    }
//    
//    // 2.判断开始触碰的时候是否选图片
//    if (self.selectedImage) {
//        // 1.1获取当前手指选中的图片
//        LWAttributedImage *selectedImage = [self touchContentOffWithPosition:position];
//        // 1.2.如果当前选中的图片和触碰开始时选中的图片不一致
//        // -> 取消当前选中
//        if (selectedImage != self.selectedImage) {
//            // 4.1取消当前选中
//            self.selectedImage = nil;
//        }
//    }
}

// 结束触摸
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    // 1.获取手指点中的坐标
    CGPoint position = [[touches anyObject] locationInView:self];
    // 1.判断结束触摸时是否还选中超文本
    if (self.selectedLink) {
        // 2.根据点中的坐标，寻找对应文字的索引
        // 2.1此处返回LWAttributedHyperlink对象，返回信息都在里面
        LWAttributedHyperlink *selectedLink = [self touchLinkWithPosition:position];
        
        // 1.1代理回调通知控制器
        if ([self.delegate respondsToSelector:@selector(expressionView:selectHyperlink:)]&&self.selectedLink==selectedLink) {
            [self.delegate expressionView:self selectHyperlink:self.selectedLink.text];
        }
        
        // 2.2取消选中
        self.selectedLink = nil;
        // 2.3刷新
        [self setNeedsDisplay];
    }
    
    
    // 2.判断结束触摸时是否还选中超文本
    if (self.selectedImage) {
        // 3.根据点中的坐标，寻找对应图片的索引
        // 3.1此处返回LWAttributedImage对象，返回信息都在里面
        LWAttributedImage *selectedImage = [self touchContentOffWithPosition:position];
        
        // 2.1.代理回调通知控制器
        if ([self.delegate respondsToSelector:@selector(expressionView:selectImage:)]&&self.selectedImage==selectedImage) {
            [self.delegate expressionView:self selectImage:self.selectedImage.position];
        }
        // 2.2.取消选中
        self.selectedImage = nil;
    }
}


-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.selectedImage = nil;
    if (self.selectedLink) {
        self.selectedLink = nil;
        [self setNeedsDisplay];
    }
}

/**
 * 检测点击位置是否在链接上
 * ->若在链接上，返回SXTAttributedLink
 *   包含超文本内容和range
 * ->如果没点中反回nil
 */
- (LWAttributedHyperlink *)touchLinkWithPosition:(CGPoint)position
{
    // 0.判断linkArr是否有值
    if (!self.hyperlinkModelArray || !self.hyperlinkModelArray.count) return nil;
    
    // 1.获取点击位置转换成字符串的偏移量，如果没有找到，则返回-1
    CFIndex index = [self touchPosition:position];
    
    // 2.如果没找到对应的索引，直接返回nil
    if (index == -1) return nil;
    
    // 3.返回被选中的链接所对应的数据模型，如果没选中SXTAttributedLink为nil
    return [self linkAtIndex:index];
}

/**
 * 监测点击的位置是否在图片上
 * ->若在链接上，返回SXTAttributedImage
 * ->如果没点中反回nil
 */
- (LWAttributedImage *)touchContentOffWithPosition:(CGPoint)position
{
    // 1.获取点击位置转换成字符串的偏移量，如果没有找到，则返回-1
    CFIndex index = [self touchPosition:position];
    
    // 2.如果没找到对应的索引，直接返回nil
    if (index == -1) return nil;
    
    // 3.判断index在哪个图片上
    // 3.1准备谓词查询语句
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"position == %@", @(index)];
    NSArray *resultArr = [self.expressionModelArray filteredArrayUsingPredicate:predicate];
    // 3.2获取符合条件的对象
    LWAttributedImage *imageData = [resultArr firstObject];
    
    return imageData;
}

/**
 * 获取点击位置转换成字符串的偏移量，如果没有找到，则返回-1
 */
- (CFIndex)touchPosition:(CGPoint)position
{
    // 1.获取LineRef的行数
    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    
    // 2.若lines不存在，返回－1
    if (!lines) return -1;
    
    // 3.获取lineRef的个数
    CFIndex lineCount = CFArrayGetCount(lines);
    
    // 4.准备旋转用的transform
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    // 5.获取每一行的位置的数组
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);
    
    // 6.遍历lines，处理每一行可能会对应的偏移值索引
    NSInteger index = -1;
    for (CFIndex idx = 0; idx < lineCount; idx ++) {
        // 6.1获取每一行的lineRef
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, idx);
        // 6.2获取每一行的rect
        CGRect flippedRect = CTLineGetTypographicBoundsAsRect(lineRef, lineOrigins[idx]);
        // 6.3翻转坐标系
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        // 6.4判断点中的点是否在这一行中
        if (CGRectContainsPoint(rect, position)) {
            // 6.5将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(position.x - CGRectGetMinX(rect),
                                                position.y - CGRectGetMinY(rect));
            // 6.6获取点击位置所处的字符位置，就是相当于点击了第几个字符
            index = CTLineGetStringIndexForPosition(lineRef, relativePoint);
        }
    }
    
    return index;
}

/**
 * 返回被选中的链接所对应的数据模型
 * 如果没选中SXTAttributedLink为nil
 */
- (LWAttributedHyperlink *)linkAtIndex:(CFIndex)index
{
    LWAttributedHyperlink *link = nil;
    
    for (LWAttributedHyperlink *linkData in self.hyperlinkModelArray) {
        // 如果index在data.range中，这证明点中链接
        if (NSLocationInRange(index, linkData.range)) {
            link = linkData;
            break;
        }
    }
    return link;
}

@end
