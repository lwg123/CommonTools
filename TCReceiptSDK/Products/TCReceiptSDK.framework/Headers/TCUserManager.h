//
//  TCUserManager.h
//  TCSearchReceiptSDKTest
//
//  Created by weiguang on 2017/12/28.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCUserManager : NSObject

/**
 存储用户账号信息
 */
+ (void)setToken:(NSString *)token;
+ (void)setEmployeeNum:(NSNumber *)num;

/**
 获取用户账号信息
 */
+ (NSString *)getToken;
+ (long)getEmployeeNum;

@end
