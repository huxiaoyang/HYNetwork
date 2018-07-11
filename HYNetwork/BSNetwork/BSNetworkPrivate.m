//
//  BSNetworkPrivate.m
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/9/26.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import "BSNetworkPrivate.h"
#import "CommonCrypto/CommonDigest.h"
#import "BSNetworkConfig.h"
#import "ResponseModel.h"
#import "BSBasicsRequest.h"
#import "BSRequest.h"
#import "YYModel.h"
#import <UIKit/UIKit.h>


@implementation BSNetworkPrivate

// 设置http 请求参数
+ (id)currentArgument:(BSRequest *)request {
    
    if (![request globalArgument] || [[request globalArgument] count] == 0) {
        
        id argument = [request requestArgument];
        return argument;
        
    } else {
        
        id argument = [request globalArgument];
        
        NSMutableDictionary *mutableArgument = [argument mutableCopy];
        NSDictionary *dict = (NSDictionary *)[request requestArgument];
        if (dict.count > 0) {
            [mutableArgument addEntriesFromDictionary:dict];
        }
        
        return mutableArgument;
    }
}


// 设置http URL
+ (NSString *)buildRequestUrl:(BSBasicsRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    BSNetworkConfig *config = [BSNetworkConfig sharedInstance];
    
    NSString *requestUrl;
    if (config.baseURL && config.baseURL.length > 0) {
        requestUrl = [NSString stringWithFormat:@"%@%@", [config baseURL], detailUrl];
    }
    return [requestUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (NSString *)md5StringFromString:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (BOOL)extractIdentity:(SecIdentityRef*)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    OSStatus securityError = errSecSuccess;
    //client certificate password
    NSDictionary*optionsDictionary = [NSDictionary dictionaryWithObject:[BSNetworkConfig sharedInstance].secretCodeWithP12
                                                                 forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data,(__bridge CFDictionaryRef)optionsDictionary,&items);
    
    if(securityError == 0) {
        CFDictionaryRef myIdentityAndTrust =CFArrayGetValueAtIndex(items,0);
        const void*tempIdentity =NULL;
        tempIdentity= CFDictionaryGetValue (myIdentityAndTrust,kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void*tempTrust =NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust,kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failedwith error code %d",(int)securityError);
        return NO;
    }
    return YES;
}

#pragma mark - Throw exceptiont
+ (void)throwExceptiont:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
#ifdef DEBUG
    
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"%@", message);
    
    UIViewController *parentVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                   }];
    NSString *title = @"异常错误";
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:title];
    [hogan addAttribute:NSForegroundColorAttributeName
                  value:[UIColor redColor]
                  range:NSMakeRange(0, title.length)];
    [alertVC setValue:hogan forKey:@"attributedTitle"];
    [alertVC addAction:action];
    [parentVC presentViewController:alertVC animated:YES completion:nil];
#endif
    
}


@end
