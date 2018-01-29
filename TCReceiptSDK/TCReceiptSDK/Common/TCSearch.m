//
//  TCSearch.m
//  TCSearchReceiptSDKTest
//
//  Created by weiguang on 2017/12/25.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "TCSearch.h"


@implementation TCSearch

+ (void)queryCompanylist:(NSString *)companyName pageSize:(int)pageSize currentPage:(int)currentPage token:(NSString *)token completeHandler:(completeHandler)complete {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@v1/invoice/list",BaseUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:token forHTTPHeaderField:@"X-CH-TouchC-Token"];
    request.HTTPMethod = @"POST";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(currentPage) forKey:@"page"];
    [params setValue:@(pageSize) forKey:@"pageSize"];
    [params setValue:companyName forKey:@"companyName"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
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

+ (UIImage *)generateQRCode:(NSString *)content width:(CGFloat)width height:(CGFloat)height {
    
    CIImage *qrcodeImage;
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    qrcodeImage = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}];
    CGImageRef cgImage =
    [context createCGImage:qrcodeImage fromRect:[qrcodeImage extent]];
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1
                                   orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    //对图片进行拉伸或压缩处理
    CGFloat scaleX = width / qrcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = height / qrcodeImage.extent.size.height;
    //指定宽高值无效时使用原图片的大小，不进行拉伸
    if(scaleX <= 0){
        scaleX = 1.0;
    }
    if(scaleY <= 0){
        scaleY = 1.0;
    }
    CGFloat scaleSize = scaleX;
    if(scaleSize > scaleY){
        scaleSize = scaleY;
    }

    CGFloat destWidth = qrcodeImage.extent.size.width * scaleSize;
    CGFloat destHeight = qrcodeImage.extent.size.height * scaleSize;
    
    UIGraphicsBeginImageContext(CGSizeMake(destWidth, destHeight));
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    [image drawInRect:CGRectMake(0, 0, destWidth, destHeight)];
    UIImage *target = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return target;
    
}

@end
