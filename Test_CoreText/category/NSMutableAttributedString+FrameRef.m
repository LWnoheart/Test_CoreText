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


@end
