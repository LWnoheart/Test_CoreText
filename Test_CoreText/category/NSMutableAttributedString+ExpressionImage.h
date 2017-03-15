//
//  NSAttributedString+ExpressionImage.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/14.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWAttributedImage.h"
@interface NSMutableAttributedString (ExpressionImage)

/**
 *@brief 对attributedString进行表情处理
 *
 *@discussion 会将符合表情字符串条件的地方（range），替换成占位字符串。
 *
 *@param imageSize 如果传入非CGSizeZero，则会将表情图片设置为imageSize大小
 *@param referenceFont 得到CTFontRef计算Ascent、Descent和baseLine，根据三者确定图片的Ascent、Descent。如果imageSize设置为CGSizeZero则图片大小为referenceFont.pointSize
 *
 *@return 返回处理字符串得到的所有表情封装对象array。
 */

-(NSArray<LWAttributedImage *> *)getAttImageWithImageSize:(CGSize)imageSize referenceFont:(UIFont *)referenceFont;

@end
