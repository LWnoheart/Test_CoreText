//
//  TextViewProperty.h
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/13.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TextViewProperty <NSObject>

#pragma mark 基础属性

@required

@property (nonatomic, strong) NSAttributedString *text;


@optional



@end


/*

[start_s+type=hyperlink+data=http://www.baidu.com+end_e]
[start_s+type=illustration+proportionWH=0.35+widthP=0.4+data=http://www.dwdwd.wdw/inug.png+end_e]


[/laugh.png]







*/
