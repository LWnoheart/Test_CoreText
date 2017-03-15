//
//  ViewController.m
//  Test_CoreText
//
//  Created by 李巍 on 2017/3/13.
//  Copyright © 2017年 李巍. All rights reserved.
//

#import "ViewController.h"
#import "TextSimpleView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    TextSimpleView *view = [[TextSimpleView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.text = [[NSAttributedString alloc] initWithString:@"明月几时有？把酒问青天。不知天上宫阙、今夕是何年？" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
