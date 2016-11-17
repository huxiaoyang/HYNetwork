//
//  BSNetworkConfig.m
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/21.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import "BSNetworkConfig.h"
#import "AFNetworking.h"

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
        _successCodeStatus = @0;
        _responseParams = @{REQUEST_DATA    : @"data",
                            REQUEST_MESSAGE : @"msg",
                            REQUEST_CODE    : @"code",
                            REQUEST_TIME    : @"timestamp"
                            };
    }
    return self;
}

@end
