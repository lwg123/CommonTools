//
//  TCBundleTool.m
//  TCSearchReceiptSDKTest
//
//  Created by weiguang on 2017/12/29.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "TCBundleTool.h"

@implementation TCBundleTool

+ (NSBundle *)getBundle {
    return [NSBundle bundleWithPath: [[NSBundle mainBundle] pathForResource:@"Bundle" ofType: @"bundle"]];
}
+ (NSString *)getBundlePath: (NSString *)bundleName{
    NSBundle *myBundle = [TCBundleTool getBundle];
    if (myBundle && bundleName) {
        return [[myBundle resourcePath] stringByAppendingPathComponent: bundleName];
    }
    return nil;
}

+ (UIImage *)getBundleImage:(NSString *)name
{
    UIImage *bundleImage = [[UIImage imageWithContentsOfFile:[[self getBundle] pathForResource:name ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return bundleImage;
}

@end
