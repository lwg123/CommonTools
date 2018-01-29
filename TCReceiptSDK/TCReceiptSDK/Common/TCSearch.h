//
//  TCSearch.h
//  TCSearchReceiptSDKTest
//
//  Created by weiguang on 2017/12/25.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completeHandler)(NSDictionary* responseObject, NSError *error);

@interface TCSearch : NSObject


/**
 * 获取公司列表
 * @param companyName - 公司名称
 *
 * @discussion 通过输入companyName来获取公司列表，默认显示全部公司.
 */
+ (void)queryCompanylist:(NSString *)companyName pageSize:(int)pageSize currentPage:(int)currentPage token:(NSString *)token completeHandler:(completeHandler)complete;

/**
 * 生成公司信息二维码
 * @param content - 公司信息内容
 * @param width - 二维码宽度
 * @param height - 二维码高度
 *
 * @discussion 通过输入companyName来搜索公司，当为空("")时，默认显示全部公司.
 */
+ (UIImage *)generateQRCode:(NSString *)content width:(CGFloat)width height:(CGFloat)height;

@end
