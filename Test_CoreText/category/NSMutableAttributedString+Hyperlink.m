//
//  NSMutableAttributedString+Hyperlink.m
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/15.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "NSMutableAttributedString+Hyperlink.h"


// 检查URL/@/##/
static NSString *const kLinkPattern = @"(@([\u4e00-\u9fa5A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)._-]+))|(#[\u4e00-\u9fa5A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)._-]+#)|((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";


@implementation NSMutableAttributedString (Hyperlink)


-(NSArray<LWAttributedHyperlink *> *)getHyperlinkWithColor:(UIColor *)color font:(UIFont *)font
{
    // 用来保存link对象的数组
    NSMutableArray *arrM = [NSMutableArray array];
    
    // 正则处理@、#、url
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kLinkPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    // 遍历获取到的link
    [regex enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        // 超文本在字符串中的范围
        NSRange range = result.range;
        // 获取对应的超文本字符串
        NSString *text = [self.string substringWithRange:range];
        
        // 初始化并设置link对象的属性
        LWAttributedHyperlink *linkData = [[LWAttributedHyperlink alloc]init];
        linkData.text = text;
        linkData.range = range;
        
        // 设置超文本字体大小和颜色
        [self setFont:font range:range];
        [self setTextColor:color range:range];
        
        // 添加进入数组
        [arrM addObject:linkData];
    }];
    
    return arrM;
}



/**
 * 设置字体大小
 */
- (void)setFont:(UIFont *)font
{
    [self setFont:font range:NSMakeRange(0, self.string.length)];
}

- (void)setFont:(UIFont *)font range:(NSRange)range
{
    // 移除以前的字体大小
    [self removeAttribute:NSFontAttributeName range:range];
    // 设置字体颜色
    [self addAttribute:NSFontAttributeName value:font range:range];
}



/**
 * 设置字体颜色
 */
- (void)setTextColor:(UIColor *)textColor
{
    [self setTextColor:textColor range:NSMakeRange(0, self.string.length)];
}

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range
{
    // 移除以前的
    [self removeAttribute:NSForegroundColorAttributeName range:range];
    // 设置字体颜色
    [self addAttribute:NSForegroundColorAttributeName value:textColor range:range];
}


@end
