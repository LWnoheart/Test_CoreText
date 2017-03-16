//
//  NSMutableAttributedString+FrameRef.m
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/15.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "NSMutableAttributedString+FrameRef.h"

@implementation NSMutableAttributedString (FrameRef)



- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect
{
    // 获取framesetterRef
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    // 获取frameRef
    CTFrameRef frameRef = [self prepareFrameRefWithRect:rect framesetterRef:framesetterRef];
    
    // 释放framesetterRef
    CFRelease(framesetterRef);
    
    return frameRef;
}


- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect framesetterRef:(CTFramesetterRef)framesetterRef
{
    // 创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    // 添加路径
    CGPathAddRect(path, NULL, rect);
    
    // 获取frameRef
    // CFRangeMake(0,0) 表示绘制全部文字
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), path, NULL);
    
    // 释放内存
    CFRelease(path);
    
    return frameRef;
}


CGRect CTRunGetTypographicBoundsForImageRect(CTRunRef runRef, CTLineRef lineRef, CGPoint lineOrigin, LWAttributedImage *imageData)
{
    // 获取对应runRef的rect
    CGRect rect = CTRunGetTypographicBoundsAsRect(runRef, lineRef, lineOrigin);
    return UIEdgeInsetsInsetRect(rect, imageData.imageInsets);
    
}

CGRect CTRunGetTypographicBoundsAsRect(CTRunRef runRef, CTLineRef lineRef, CGPoint lineOrigin)
{
    // 上行高度
    CGFloat ascent;
    // 下行高度
    CGFloat descent;
    // 宽度
    CGFloat width = CTRunGetTypographicBounds(runRef, CFRangeMake(0, 0), &ascent, &descent, NULL);
    // 高度
    CGFloat height = ascent + descent;
    
    // 当前runRef距离lineOrigin的偏移值
    CGFloat offsetX = CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(runRef).location, NULL);
    
    // 返回计算好的rect
    return CGRectMake(lineOrigin.x + offsetX,
                      lineOrigin.y - descent,
                      width,
                      height);
}



/**
 * 获取每一行(lineRef)的rect
 */
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef lineRef, CGPoint lineOrigin)
{
    // 上行高度
    CGFloat ascent;
    // 下行高度
    CGFloat descent;
    // 宽度
    CGFloat width = CTLineGetTypographicBounds(lineRef, &ascent, &descent, NULL);
    // 高度
    CGFloat height = ascent + descent;
    
    return CGRectMake(lineOrigin.x,
                      lineOrigin.y - descent,
                      width,
                      height);
}



/**
 * CFRange -->NSRange
 */
NSRange NSRangeFromCFRange(CFRange range)
{
    return NSMakeRange(range.location, range.length);
}

/**
 * 判断当前行中是否包含超文本链接
 */
BOOL CTLineContainsCharactersFromStringRange(CTLineRef lineRef, NSRange range)
{
    // 1.获取当前行在文本中的范围
    CFRange lineCFRange = CTLineGetStringRange(lineRef);
    
    // 2.CFRange->NSRange
    NSRange lineNSRange = NSRangeFromCFRange(lineCFRange);
    
    // 3.判断linkRange是否在lineNSRange范围内
    NSRange intersectedRange = NSIntersectionRange(lineNSRange, range);
    
    // 4.返回是否包含,不包含返回YES
    return (intersectedRange.length > 0) ? NO : YES;
}




/**
 * 判断当前runRef(CTRunRef)中是否包含超文本链接
 */
BOOL CTRunContainsCharactersFromStringRange(CTRunRef runRef, NSRange range)
{
    // 1.获取当前runRef在文本中的范围
    CFRange runCFRange = CTRunGetStringRange(runRef);
    
    // 2.CFRange->NSRange
    NSRange runNSRange = NSRangeFromCFRange(runCFRange);
    
    // 3.判断linkRange是否在lineNSRange范围内
    NSRange intersectedRange = NSIntersectionRange(runNSRange, range);
    
    // 4.返回是否包含,不包含返回YES
    return (intersectedRange.length > 0) ? NO : YES;
}

/**
 * 获取点中link的rect
 */
CGRect CTRunGetTypographicBoundsForLinkRect(CTLineRef lineRef, NSRange range, CGPoint lineOrigin)
{
    // 0.link的rect
    CGRect highlightRect = CGRectZero;
    
    // 1.判断linkRange是否在当前行的runRef中
    // 1.1获取runRef所在的数组
    CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
    // 1.2获取runRef的个数
    CFIndex runCount = CFArrayGetCount(runs);
    // 1.3循环遍历当前行的runRef，确定link的位置
    for (CFIndex idx = 0; idx < runCount; idx ++) {
        // 1.3.1获取对应位置的runRef
        CTRunRef runRef = CFArrayGetValueAtIndex(runs, idx);
        // 1.3.2判断当run(CTRunRef)中是否有包含link
        if (CTRunContainsCharactersFromStringRange(runRef, range)) continue;
        // 1.3.3获取点中link的rect
        CGRect linkRect = CTRunGetTypographicBoundsAsRect(runRef, lineRef, lineOrigin);
        // 1.3.4把runRef中的rect拼接在一起
        // CGRectUnion-> 返回两个矩形的并集
        highlightRect = CGRectIsEmpty(highlightRect) ? linkRect : CGRectUnion(highlightRect, linkRect);
    }
    
    return highlightRect;
}

@end
