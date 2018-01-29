//
//  ViewController.m
//  testSDK
//
//  Created by weiguang on 2017/12/27.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "ViewController.h"
#import <TCReceiptSDK/CHQueryViewController.h>

#define tokenStr @"78231432cd2347cd807c5c8234f284ee"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CHQueryViewController *vc = [[CHQueryViewController alloc] init];
    vc.token = tokenStr;
    vc.employeeNum = 20192883;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
