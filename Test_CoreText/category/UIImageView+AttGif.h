//
//  UIImage+AttGif.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/14.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWAttributedImage.h"



@interface NSString (imageType)

/**
 * 判断图片类型
 */
+ (LWAttributedImageType)contentTypeForImageName:(NSString *)imageName;

@end


@interface UIImageView (AttGif)


/**
 * 加载指定GIF图片并创建UIImageView
 * ->imageName一定要加上.gif
 */
+ (UIImageView *)imageViewWithGIFName:(NSString *)imageName
                                frame:(CGRect)frame;
@end
