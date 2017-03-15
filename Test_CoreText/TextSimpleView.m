//
//  TextSimpleView.m
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/13.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "TextSimpleView.h"
@import CoreText;
@implementation TextSimpleView

@synthesize text;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//    // Drawing code
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    // 2.翻转坐标系
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, rect.size.height), 1.f, -1.f);
    CGContextConcatCTM(ref, transform);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    //限定path范围，定义字符串
    CGPathAddRect(path, NULL, rect);
    
    //CTFramesetter管理你的字体引用和你的文本绘制框架。
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.text);
    //3
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.text.length), path, NULL);
    CTFrameDraw(frame, ref);
    //4
    CFRelease(framesetter);
    //5
    CFRelease(path);
    
    CFRelease(frame);
}



@end
