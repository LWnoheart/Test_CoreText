//
//  NSMutableAttributedString+Hyperlink.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/15.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWAttributedHyperlink.h"
@import UIKit;
@interface NSMutableAttributedString (Hyperlink)


-(NSArray<LWAttributedHyperlink *> *)getHyperlinkWithColor:(UIColor *)color font:(UIFont *)font;

@end
