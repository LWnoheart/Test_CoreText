//
//  TextExpressionView.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/15.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextExpressionView : UIView

@property (nonatomic, strong) NSAttributedString *text;

@property (nonatomic, assign) CGSize expressionSize;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, assign) NSInteger numberOfLines;

@end
