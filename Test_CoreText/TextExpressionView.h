//
//  TextExpressionView.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/15.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextExpressionViewDelegate;

@interface TextExpressionView : UIView

@property (nonatomic, strong) NSAttributedString *text;

@property (nonatomic, assign) CGSize expressionSize;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, assign) NSInteger numberOfLines;

@property (nonatomic, strong) UIColor *hyperlinkColor;
@property (nonatomic, strong) UIColor *hyperlinkBackgroundColor;

@property (nonatomic, weak)id<TextExpressionViewDelegate>delegate;

@end


@protocol TextExpressionViewDelegate <NSObject>

@optional
-(void)expressionView:(TextExpressionView *)view selectHyperlink:(NSString *)hyperlink;

-(void)expressionView:(TextExpressionView *)view selectImage:(NSInteger)imageIndex;

@end
