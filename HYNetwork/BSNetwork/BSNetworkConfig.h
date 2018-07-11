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



extern NSString *const REQUEST_DATA;        // json data 数据的key
extern NSString *const REQUEST_MESSAGE;     // json message 信息的key
extern NSString *const REQUEST_CODE;        // json code 状态码的key
extern NSString *const REQUEST_TIME;        // json time 时间的key 


@interface BSNetworkConfig : NSObject

+ (instancetype)sharedInstance;

// 网络请求基地址
@property (nonatomic, copy) NSString *baseURL;


@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

// p12密码
@property (nonatomic, copy, readonly) NSString *secretCodeWithP12;

// 请求返回json的主要字段
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *responseParams;


// 请求成功的状态码 - 默认是@0
@property (nonatomic, strong) NSNumber *successCodeStatus;


// 参数处理中间件
@property (nonatomic, strong, readonly) id<BSParametersFilterProtocol> parametersFilter;

// json to model 中间件
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
- (id)responseModel:(id)responseObject request:(BSBasicsRequest *)request;

@concrete
- (id)responseModel:(NSError *)error;

@end


// 默认的 BSFetchResponseModelFilterProtocol 实现
@interface BSDefaultFetchResponseModelFilter: NSObject <BSFetchResponseModelFilterProtocol>


@end




