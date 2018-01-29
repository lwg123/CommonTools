//
//  TCRequestManager.m
//  TCSearchReceiptSDKTest
//
//  Created by weiguang on 2017/12/27.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "TCRequestManager.h"

@implementation TCRequestManager

+ (TCRequestManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    static TCRequestManager *mangaer = nil;
    dispatch_once(&onceToken, ^{
        mangaer = [[TCRequestManager alloc] init];
    });
    return mangaer;
}

- (void)postPath:(NSString *)urlStr
       paramters:(NSDictionary *)paramters
 completeHandler:(completeHandler)complete{
    
    [self postPath:urlStr token:nil paramters:paramters completeHandler:complete];
}

- (void)postPath:(NSString *)urlStr
           token:(NSString *)token
       paramters:(NSDictionary *)paramters
 completeHandler:(completeHandler)complete {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (token != nil) {
        [request addValue:token forHTTPHeaderField:@"X-CH-TouchC-Token"];
    }
    request.HTTPMethod = @"POST";
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramters options:kNilOptions error:nil];
    [request setHTTPBody:data];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil && data.length > 0) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (dict == nil) {
                if (complete) {
                    complete(@{@"reason":@"数据错误",@"code":@"1"},nil);
                }
            }else{
                if (complete) {
                    complete(dict,nil);
                }
            }
        }else {
            
            if (error) {
                NSLog(@"sendmsg error=%@",[error localizedDescription]);
                if (complete) {
                    complete(@{@"reason":[error localizedDescription],@"code":@"999"},error);
                }
            }else{
                if (complete) {
                    complete(@{@"reason":@"请求失败",@"code":@"999"},error);
                }
            }
            
        }
        
    }];
    [task resume];
    
    
}

@end
