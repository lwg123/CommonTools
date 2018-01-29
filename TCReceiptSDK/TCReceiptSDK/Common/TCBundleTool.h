//
//  TCBundleTool.h
//  TCSearchReceiptSDKTest
//
//  Created by weiguang on 2017/12/29.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCBundleTool : NSObject

+ (NSString *)getBundlePath: (NSString *)bundleName;
+ (NSBundle *)getBundle;
+ (UIImage *)getBundleImage:(NSString *)name;
@end
