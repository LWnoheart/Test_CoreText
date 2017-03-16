//
//  NSMutableAttributedString+FrameRef.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/15.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWAttributedImage.h"
@import CoreText;
@interface NSMutableAttributedString (FrameRef)

/**
 *@brief 根据rect创建CTFrame
 *
 *@discussion 根据画图范围，利用CTFramesetter来创建
 *
 *@param rect 画图的范围
 *
 *@return CTFrameRef,用来确定文字绘制的最终frame，（CTFrame->CTLine->CTRun）
 */
- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect;


/**
 *@brief 根据rect和framesetter创建CTFrame
 *
 *@discussion 绘制整个字符串
 *
 *@param rect 画图的范围
 *@param framesetterRef 依据CTFramesetterCreateWithAttributedString创建的setter
 *
 *@return CTFrameRef,用来确定文字绘制的最终frame
 */
- (CTFrameRef)prepareFrameRefWithRect:(CGRect)rect framesetterRef:(CTFramesetterRef)framesetterRef;


/*!
 *@function CTRunGetTypographicBoundsForImageRect
 *@abstract 获得表情插图的rect
 *@discussion 根据表情占位的参数获得图片在所绘制文本的位置
 *
 *@param runRef 表情插图占位所属
 *@param lineRef 表情插图占位所属
 *@param lineOrigin 表情插图占位所属
 *@param imageData 表情插图model，用于取imageInsets
 */
CGRect CTRunGetTypographicBoundsForImageRect(CTRunRef runRef, CTLineRef lineRef, CGPoint lineOrigin, LWAttributedImage *imageData);


/*!
 *@function CTLineGetTypographicBoundsAsRect
 *@abstract 获得CTLine的排版位置frame
 *
 *@param lineRef CTLine
 *@param lineOrigin CTLine所在的origin，CTFrameGetLineOrigins
 */
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef lineRef, CGPoint lineOrigin);




/*!
 *@function CTLineContainsCharactersFromStringRange
 *@abstract 判断range是否在当前行
 *
 *@param lineRef 判断是否在的行CTLine
 *@param range 整体渲染string需要判断的位置NSRange
 */
BOOL CTLineContainsCharactersFromStringRange(CTLineRef lineRef, NSRange range);


/*!
 *@function CTRunGetTypographicBoundsForLinkRect
 *@abstract 获得渲染string所在行的位置frame
 *
 *@param lineRef 渲染string所在行CTLine
 *@param range 整体渲染string的range
 *@param lineOrigin 渲染string所在行CTLine的origin，CTFrameGetLineOrigins
 */
CGRect CTRunGetTypographicBoundsForLinkRect(CTLineRef lineRef, NSRange range, CGPoint lineOrigin);
@end
