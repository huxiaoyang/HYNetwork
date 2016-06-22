//
//  BSNetworkConfig.m
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/21.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import "BSNetworkConfig.h"


NSString *const REQUEST_DATA      = @"data";
NSString *const REQUEST_MESSAGE   = @"message";
NSString *const REQUEST_CODE      = @"code";
NSString *const REQUEST_TIME      = @"timestamp";


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
        _cacheExpirationInterval = 0;
        _successCodeStatus = @0;
        _responseParams = @{REQUEST_DATA    : @"data",
                            REQUEST_MESSAGE : @"msg",
                            REQUEST_CODE    : @"code",
                            REQUEST_TIME    : @"timestamp"
                            };
    }
    return self;
}

- (void)setCacheExpirationInterval:(NSTimeInterval)cacheExpirationInterval {
    _cacheExpirationInterval = cacheExpirationInterval;
    if (cacheExpirationInterval > 0) {
        BSCustomURLCache *sharedCache = [BSCustomURLCache standardURLCache];
        sharedCache.cacheExpirationInterval = cacheExpirationInterval;
        sharedCache.customURLCachePolicy = BSRequestUseCacheWhenAnytime;
        [NSURLCache setSharedURLCache:sharedCache];
    }
}

- (void)setCustomURLCachePolicy:(BSCustomURLCachePolicy)customURLCachePolicy {
    _customURLCachePolicy = customURLCachePolicy;
    if (self.cacheExpirationInterval > 0) {
        [[BSCustomURLCache standardURLCache] setCustomURLCachePolicy:customURLCachePolicy];
    } else {
        NSAssert(NO, @"先设置cacheExpirationInterval来开启缓存，然后再设置缓存策略");
    }
}

@end
