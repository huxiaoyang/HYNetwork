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
#import "BSRequest.h"
#import "YYModel.h"


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
+ (NSString *)buildRequestUrl:(BSRequest *)request {
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
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

#pragma mark - json to model
+ (id)responseModel:(id)responseObject request:(BSRequest *)request {
    BSNetworkConfig *config = [BSNetworkConfig sharedInstance];

    NSString * requestData = config.responseParams[REQUEST_DATA];
    NSString * requestCode = config.responseParams[REQUEST_CODE];
    NSString * requestMsg  = config.responseParams[REQUEST_MESSAGE];
    NSString * requestTime = config.responseParams[REQUEST_TIME];
    
    
    if ([responseObject isKindOfClass:[NSArray class]]) {
        ResponseModel *model = [[ResponseModel alloc] init];
        model.code = config.successCodeStatus;
        model.message = @"request is success";
        model.timestamp = @([[NSDate date] timeIntervalSince1970]);
        model.data = [NSArray yy_modelArrayWithClass:[request modelClass] json:responseObject];
        return model;
    }
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        
        ResponseModel *model = [[ResponseModel alloc] init];
        
        if (![[responseObject allKeys] containsObject:requestData] && ![[responseObject allKeys] containsObject:requestCode]) {
            model.code = config.successCodeStatus;
            model.message = @"request is success";
            model.timestamp = @([[NSDate date] timeIntervalSince1970]);
            model.data = [NSDictionary yy_modelDictionaryWithClass:[request modelClass] json:responseObject];
            return model;
        }
        
        if ([[responseObject allKeys] containsObject:requestCode]) {
            model.code = responseObject[requestCode];
        }
        
        if ([[responseObject allKeys] containsObject:requestMsg]) {
            model.message = responseObject[requestMsg];
        }
        
        if ([[responseObject allKeys] containsObject:requestTime]) {
            model.timestamp = responseObject[requestTime];
        }
        
        if (![[responseObject allKeys] containsObject:requestData]) {
            model.data = nil;
            return model;
        }
        
        if (![responseObject[requestData] isKindOfClass:[NSDictionary class]] && ![responseObject[requestData] isKindOfClass:[NSArray class]]) {
            model.data = responseObject[requestData];
            return model;
        }
        
        if ([responseObject[requestData] count] == 0 || [responseObject[requestData] isEqual:[NSNull null]]) {
            model.data = nil;
            return model;
        }
        
        if ([responseObject[requestData] isKindOfClass:[NSArray class]]) {
            
            NSArray *items = responseObject[requestData];
            if (items.count == 0) {
                model.data = items;
                return model;
            }
            
            if (![[items firstObject] isKindOfClass:[NSDictionary class]]) {
                model.data = items;
                return model;
            }
            
            model.data = [NSArray yy_modelArrayWithClass:[request modelClass] json:responseObject[requestData]];
            return model;
        }
        
        if ([responseObject[requestData] isKindOfClass:[NSDictionary class]]) {
            model.data = [[request modelClass] yy_modelWithJSON:responseObject[requestData]];
            return model;
        }
        
        return model;
    }
    
    return nil;
}


+ (id)responseModel:(NSError *)error {
    ResponseModel *model = [[ResponseModel alloc] init];
    model.code = @(error.code);
    model.timestamp = @([[NSDate date] timeIntervalSince1970]);
#ifdef DEBUG
    model.message = error.localizedDescription;
#else
    switch (error.code) {
        case -1009: // 没有网络
            model.message = @"失去网络链接,请检查您的网络设置!";
            break;
        case -1001: // 请求超时
            model.message = @"网络状态不好,请稍候再试";
            break;
        default:
            model.message = @"网络问题，稍后再试";
            break;
    }
#endif
    
    return model;
}

@end
