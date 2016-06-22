//
//  BSNetworkConfig.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/21.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSCustomURLCache.h"
#import "AFNetworking.h"

extern NSString *const REQUEST_DATA;        // json data 数据
extern NSString *const REQUEST_MESSAGE;     // json message 信息
extern NSString *const REQUEST_CODE;        // json code 状态码
extern NSString *const REQUEST_TIME;        // json time 时间


@interface BSNetworkConfig : NSObject

+ (instancetype)sharedInstance;

// 网络请求基地址
@property (nonatomic, strong) NSString *baseURL;


@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;


// 请求返回json的主要字段
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *responseParams;


// 请求成功的状态码 - 默认是@0
@property (nonatomic, strong) NSNumber *successCodeStatus;


// 缓存时间，默认不开启，不为0时开启 - 只用于GET请求
@property (nonatomic, assign) NSTimeInterval cacheExpirationInterval;


// 自定义缓存策略
@property (nonatomic, assign) BSCustomURLCachePolicy customURLCachePolicy;


@end
