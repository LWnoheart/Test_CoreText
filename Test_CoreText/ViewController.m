//
//  ViewController.m
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/13.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "ViewController.h"
#import "TextSimpleView.h"
#import "TextExpressionView.h"
@import CoreAudio;
@interface ViewController ()<TextExpressionViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    // Do any additional setup after loading the view, typically from a nib.
    TextSimpleView *view = [[TextSimpleView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.text = [[NSAttributedString alloc] initWithString:@"明月几时有？把酒问青天。不知天上宫阙、今夕是何年？" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.view addSubview:view];
    
    
    TextExpressionView *eView = [[TextExpressionView alloc]init];
    eView.frame = CGRectMake(100, 300, 200, 200);
    eView.numberOfLines = 0;
    eView.delegate = self;
    eView.hyperlinkColor = [UIColor purpleColor];
    eView.hyperlinkBackgroundColor = [UIColor redColor];
    eView.text = [[NSAttributedString alloc] initWithString:@"明月几时有？把酒问青天。不知天上宫阙、今夕是何年？我欲乘风归去，惟恐琼楼玉宇，高处不胜寒．起舞弄清影，何似在人间？[/cahan.gif]  转朱阁，低绮户，照无眠。www.baidu.com不应有恨、何事长向别时圆？人有悲欢离合，月有阴晴圆缺，此事古难全。但愿人长久，[/haha]千里共蝉娟。" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [self.view addSubview:eView];
}

-(void)expressionView:(TextExpressionView *)view selectHyperlink:(NSString *)hyperlink
{
//    NSLog(@"hyperlink=%@",hyperlink);
}

-(void)expressionView:(TextExpressionView *)view selectImage:(NSInteger)imageIndex
{
//    NSLog(@"index=%ld",(long)imageIndex);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

/*

明月几时有？把酒问青天。不知天上宫阙、今夕是何年？我欲乘风归去，惟恐琼楼玉宇，高处不胜寒．起舞弄清影，何似在人间？  转朱阁，低绮户，照无眠。不应有恨、何事长向别时圆？人有悲欢离合，月有阴晴圆缺，此事古难全。但愿人长久，千里共蝉娟。

*/
