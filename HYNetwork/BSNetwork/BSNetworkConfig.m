//
//  BSNetworkConfig.m
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/21.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import "BSNetworkConfig.h"
#import "AFNetworking.h"
#import "ResponseModel.h"
#import "BSRequest.h"

#if __has_include(<YYModel/YYModel.h>)
#import <YYModel/YYModel.h>
#endif


NSString *const REQUEST_DATA      = @"com.XiaoYang.json.data";
NSString *const REQUEST_MESSAGE   = @"com.XiaoYang.json.message";
NSString *const REQUEST_CODE      = @"com.XiaoYang.json.code";
NSString *const REQUEST_TIME      = @"com.XiaoYang.json.timestamp";


@implementation BSNetworkConfig

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        _secretCodeWithP12 = nil;
        _successCodeStatus = @0;
        _parametersFilter = nil;
        _fetchResponseModelFilter = [[BSDefaultFetchResponseModelFilter alloc] init];
        _responseParams = @{REQUEST_DATA    : @"data",
                            REQUEST_MESSAGE : @"msg",
                            REQUEST_CODE    : @"code",
                            REQUEST_TIME    : @"timestamp"
                            };
    }
    return self;
}

- (void)setP12SecretCode:(NSString *)secretCode {
    if (secretCode && ![secretCode isKindOfClass:[NSNull class]] && secretCode.length > 0) {
        _secretCodeWithP12 = secretCode;
    }
}

- (void)setParametersFilter:(id<BSParametersFilterProtocol>)filter {
    _parametersFilter = filter;
}

- (void)setFetchResponseModelFilter:(id<BSFetchResponseModelFilterProtocol>)filter {
    _fetchResponseModelFilter = filter;
}

@end




/**
 json to model -> protocol的默认实现
 */

@concreteprotocol(BSFetchResponseModelFilterProtocol)

- (id)responseModel:(id)responseObject request:(BSBasicsRequest *)request {
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


- (id)responseModel:(NSError *)error {
    
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
        case -999: // 主动取消网络请求操作，不需要toast，返回nil
            model.message = nil;
            break;
        default:
            model.message = @"网络问题，稍后再试";
            break;
    }
#endif
    
    return model;
}


@end



@implementation BSDefaultFetchResponseModelFilter


@end



