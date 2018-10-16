//
//  BSNetworkConfig.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/21.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libextobjc/EXTConcreteProtocol.h>

@class AFSecurityPolicy;
@class BSBasicsRequest;
@protocol BSParametersFilterProtocol;
@protocol BSFetchResponseModelFilterProtocol;


typedef NSString * BSResponseKey;
typedef NSDictionary  <BSResponseKey, NSArray <NSString *> *> BSResponseParamsDic;

FOUNDATION_EXTERN BSResponseKey const BSResponseDataKey;        // json data 数据的key
FOUNDATION_EXTERN BSResponseKey const BSResPonseMessageKey;     // json message 信息的key
FOUNDATION_EXTERN BSResponseKey const BSResPonseTimeKey;        // json time 时间的key

FOUNDATION_EXTERN NSString * const BSResponseSuccessCode;


@interface BSNetworkConfig : NSObject

+ (instancetype)sharedInstance;

/// 网络请求基地址
@property (nonatomic, copy) NSString *baseURL;


@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/// p12密码
@property (nonatomic, copy, readonly) NSString *secretCodeWithP12;

/// 请求返回json第一层的主要字段
/// value为取值字段数组 例：{: @[@"data", @"result"]}
@property (nonatomic, strong) BSResponseParamsDic *responseParams;

/// 请求返回response中包含的判断请求是否成功的字段，一般为code
/// key为字段名 value为成功的值，可以设置多组，例： {@"code" : @"200", @"result" : @"0"}
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *successCodeDic;


/// 参数处理中间件
@property (nonatomic, strong, readonly) id<BSParametersFilterProtocol> parametersFilter;

/// json to model 中间件
@property (nonatomic, strong, readonly) id<BSFetchResponseModelFilterProtocol> fetchResponseModelFilter;


- (void)setP12SecretCode:(NSString *)secretCode;

#pragma mark - set filter

- (void)setParametersFilter:(id<BSParametersFilterProtocol>)filter;

- (void)setFetchResponseModelFilter:(id<BSFetchResponseModelFilterProtocol>)filter;

@end




/**
 参数过滤或者加密
 */
@protocol BSParametersFilterProtocol <NSObject>

- (id)filterParameter:(id)parameter request:(BSBasicsRequest *)request;

@end



/**
 json to model
 重写Protocol可以切换 json to model 实现方式
 */
@protocol BSFetchResponseModelFilterProtocol <NSObject>

@concrete
- (id)responseModel:(id)responseJson request:(BSBasicsRequest *)request;

@concrete
- (id)responseModel:(NSError *)error;

@end


// 默认的 BSFetchResponseModelFilterProtocol 实现
@interface BSDefaultFetchResponseModelFilter: NSObject <BSFetchResponseModelFilterProtocol>


@end




