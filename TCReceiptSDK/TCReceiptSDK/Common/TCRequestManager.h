//
//  TCRequestManager.h
//  TCSearchReceiptSDKTest
//
//  Created by weiguang on 2017/12/27.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completeHandler)(NSDictionary* responseObject, NSError *error);

@interface TCRequestManager : NSObject

+ (TCRequestManager *)sharedManager;

/**
 * 网络请求接口,请求头不带token
 * @param urlStr - 请求url
 * @param paramters - 请求参数
 * @param complete - 请求完成后的回调
 *
 * @discussion 网络请求接口.
 */
- (void)postPath:(NSString *)urlStr
       paramters:(NSDictionary *)paramters
 completeHandler:(completeHandler)complete;

/**
 * 网络请求接口
 * @param urlStr - 请求url
 * @param token - token
 * @param paramters - 请求参数
 * @param complete - 请求完成后的回调
 *
 * @discussion 网络请求接口.
 */
- (void)postPath:(NSString *)urlStr
           token:(NSString *)token
       paramters:(NSDictionary *)paramters
 completeHandler:(completeHandler)complete;

@end
