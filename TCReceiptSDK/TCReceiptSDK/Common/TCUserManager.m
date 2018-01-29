//
//  TCUserManager.m
//  TCSearchReceiptSDKTest
//
//  Created by weiguang on 2017/12/28.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "TCUserManager.h"

@implementation TCUserManager

+ (void)setToken:(NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"CH_TOKEN"];
    [defaults synchronize];
}
+ (void)setEmployeeNum:(NSNumber *)num {
    if (!num) {
        num = [[NSNumber alloc]initWithInt:0];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:num forKey:@"CH_EMPLOYEENUM"];
    [defaults synchronize];
}

/******************************* 用户信息获取 ***************************************/

+ (NSString *)getToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"CH_TOKEN"];
}

+ (long)getEmployeeNum
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"CH_EMPLOYEENUM"] integerValue];
}

@end
