//
//  LWAttributedHyperlink.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/16.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWAttributedHyperlink : NSObject

/**
 * 超链接文本内容
 */
@property (nonatomic, copy) NSString *text;

/**
 * 超文本内容在字符串中所在的位置
 */
@property (nonatomic, assign) NSRange range;

@end
