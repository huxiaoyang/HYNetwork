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


BSResponseKey const BSResponseDataKey      = @"com.XiaoYang.json.data";
BSResponseKey const BSResPonseMessageKey   = @"com.XiaoYang.json.message";
BSResponseKey const BSResPonseTimeKey      = @"com.XiaoYang.json.timestamp";

NSString * const BSResponseSuccessCode    = @"200";


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
        _parametersFilter = nil;
        _fetchResponseModelFilter = [[BSDefaultFetchResponseModelFilter alloc] init];
        _responseParams = @{ BSResponseDataKey    : @[@"data"],
                            BSResPonseMessageKey : @[@"msg"],
                            BSResPonseTimeKey    : @[@"timestamp"]
                            };
        _successCodeDic = @{@"code" : @"0"};
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

- (id)responseModel:(id)responseJson request:(BSBasicsRequest *)request {
    BSNetworkConfig *config = [BSNetworkConfig sharedInstance];
    
    NSArray * dataValues = config.responseParams[BSResponseDataKey];
    NSArray * codeValues = config.successCodeDic.allKeys;
    NSArray * messageValues  = config.responseParams[BSResPonseMessageKey];
    NSArray * timeValues = config.responseParams[BSResPonseTimeKey];
    
    if ([responseJson isKindOfClass:[NSArray class]]) {
        ResponseModel *model = [[ResponseModel alloc] init];
        model.code = BSResponseSuccessCode;
        model.message = @"request is success";
        model.timestamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
        model.data = [NSArray yy_modelArrayWithClass:[request modelClass] json:responseJson];
        return model;
    }
    
    if ([responseJson isKindOfClass:[NSDictionary class]]) {
        
        ResponseModel *model = [[ResponseModel alloc] init];
        
        BOOL isContainsData = NO;
        BOOL isContainsCode = NO;
        BOOL isContainsMessage = NO;
        BOOL isContainsTime = NO;
        
        NSString *dataKey = nil;
        NSString *codeKey = nil;
        NSString *messageKey = nil;
        NSString *timeKey = nil;
        
        for (NSString *data in dataValues) {
            if ([[responseJson allKeys] containsObject:data]) {
                isContainsData = YES;
                dataKey = data;
                break;
            }
        }
        
        for (NSString *code in codeValues) {
            if ([[responseJson allKeys] containsObject:code]) {
                isContainsCode = YES;
                codeKey = code;
                break;
            }
        }
        
        for (NSString *message in messageValues) {
            if ([[responseJson allKeys] containsObject:message]) {
                isContainsMessage = YES;
                messageKey = message;
                break;
            }
        }
        
        for (NSString *time in timeValues) {
            if ([[responseJson allKeys] containsObject:time]) {
                isContainsTime = YES;
                timeKey = time;
                break;
            }
        }
        
        if (!isContainsData && !isContainsCode) {
            model.code = BSResponseSuccessCode;
            model.message = @"request is success";
            model.timestamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
            model.data = [NSDictionary yy_modelDictionaryWithClass:[request modelClass] json:responseJson];
            return model;
        }
        
        if (isContainsCode) {
            if ([responseJson[codeKey] isKindOfClass:NSString.class]) {
                if ([responseJson[codeKey] isEqualToString:config.successCodeDic[codeKey]]) {
                    model.code = BSResponseSuccessCode;
                } else {
                    model.code = responseJson[codeKey];
                }
            }
            
            if ([responseJson[codeKey] isKindOfClass:NSNumber.class]) {
                if ([((NSNumber *)responseJson[codeKey]).stringValue isEqualToString:config.successCodeDic[codeKey]]) {
                    model.code = BSResponseSuccessCode;
                } else {
                    model.code = ((NSNumber *)responseJson[codeKey]).stringValue;
                }
            }
        }
        
        if (isContainsMessage) {
            model.message = responseJson[messageKey];
        }
        
        if (isContainsTime) {
            model.timestamp = responseJson[timeKey];
        }

        if (!isContainsData) {
            if ([model.code isEqualToString:BSResponseSuccessCode] && ((NSDictionary *)responseJson).count > 1) {
                model.data = [[request modelClass] yy_modelWithJSON:responseJson];
            } else {
                model.data = nil;
            }
            return model;
        }

        if ([responseJson[dataKey] isEqual:[NSNull null]]) {
            model.data = nil;
            return model;
        }
        
        if ([responseJson[dataKey] count] == 0) {
            model.data = nil;
            return model;
        }

        if ([responseJson[dataKey] isKindOfClass:NSArray.class]) {
            NSArray *items = responseJson[dataKey];
            if (![[items firstObject] isKindOfClass:[NSDictionary class]]) {
                model.data = items;
                return model;
            }
            model.data = [NSArray yy_modelArrayWithClass:[request modelClass] json:responseJson[dataKey]];
            return model;
        }
        
        if ([responseJson[dataKey] isKindOfClass:NSDictionary.class]) {
            model.data = [[request modelClass] yy_modelWithJSON:responseJson[dataKey]];
            return model;
        }
        
        return model;
    }
    
    return nil;
}


- (id)responseModel:(NSError *)error {
    
    ResponseModel *model = [[ResponseModel alloc] init];
    model.code = @(error.code).stringValue;
    model.timestamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
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



