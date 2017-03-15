//
//  LWAttributedImage.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/14.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreText;
@import UIKit;


typedef NS_ENUM(NSInteger ,LWAttributedImageType) {
    LWImageTypePNG,//包括jpg类型
    LWImageTypeGIF,
    LWImageTypeURL//网络图片
};
@interface LWAttributedImage : NSObject

@property (nonatomic,strong)NSString *imageString;

@property (nonatomic,assign)CGSize imageSize;

@property (nonatomic,assign)NSRange imageRange;

@property (nonatomic,assign)LWAttributedImageType imageType;

@property (nonatomic,assign)CTFontRef fontRef;

@property (nonatomic,assign)UIEdgeInsets imageInsets;

@end
