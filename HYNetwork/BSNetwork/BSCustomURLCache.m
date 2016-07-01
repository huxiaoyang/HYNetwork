//
//  BSCustomURLCache.m
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/29.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import "BSCustomURLCache.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>


static NSString *const CustomURLCacheExpirationKey = @"com.XiaoYang.CustomURLCacheExpiration";

static const void *CustomURLCacheDateKey = @"com.XiaoYang.CustomURLCacheDateKey";



@implementation BSCustomURLCache


+ (instancetype)standardURLCache {
    static BSCustomURLCache *_standardURLCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _standardURLCache = [[BSCustomURLCache alloc]
                             initWithMemoryCapacity:(2 * 1024 * 1024)
                             diskCapacity:(100 * 1024 * 1024)
                             diskPath:nil];
    });
    return _standardURLCache;
}

#pragma mark - NSURLCache
                  
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSCachedURLResponse *cachedResponse = [super cachedResponseForRequest:request];

    // 在这里限制只允许GET请求缓存
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        if (cachedResponse) {
            [self removeCachedResponseForRequest:request];
        }
        return nil;
    }
    
    if (self.cacheExpirationInterval <= 0) {
        if (cachedResponse) {
            [self removeCachedResponseForRequest:request];
        }
        return nil;
    }
    
    if (self.customURLCachePolicy == BSRequestUseCacheWhenNoNetwork) {
        if ([BSCustomURLCache isHasNetWork]) {
            if (cachedResponse) {
                [self removeCachedResponseForRequest:request];
            }
            return nil;
        }
    }
    
    if (cachedResponse) {
        NSDate* cacheDate = cachedResponse.userInfo[CustomURLCacheExpirationKey];
        objc_setAssociatedObject(request, &CustomURLCacheDateKey, cacheDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        NSDate* cacheExpirationDate = [cacheDate dateByAddingTimeInterval:self.cacheExpirationInterval];
        if ([cacheExpirationDate compare:[NSDate date]] == NSOrderedAscending) {
            [self removeCachedResponseForRequest:request];
            return nil;
        }
    }

    return cachedResponse;
}


- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse
                 forRequest:(NSURLRequest *)request {
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super storeCachedResponse:cachedResponse forRequest:request];
    }
    
    if (self.cacheExpirationInterval <= 0) {
        return [super storeCachedResponse:cachedResponse forRequest:request];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:cachedResponse.userInfo];
    
    NSDate* cacheDate = objc_getAssociatedObject(request, &CustomURLCacheDateKey);
    NSDate* cacheExpirationDate = [cacheDate dateByAddingTimeInterval:self.cacheExpirationInterval];
    userInfo[CustomURLCacheExpirationKey] = [cacheExpirationDate compare:[NSDate date]] == NSOrderedDescending ? cacheDate : [NSDate date];
    
    NSCachedURLResponse *modifiedCachedResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:userInfo storagePolicy:cachedResponse.storagePolicy];
    
    [super storeCachedResponse:modifiedCachedResponse forRequest:request];
}


#pragma mark - private method
+ (BOOL)isHasNetWork {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    BOOL state = NO;
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            
            switch (netType) {
                case 0:
                    state = NO;
                    break;
                default:
                    state = YES;
                    break;
            }
        }
    }
    return state;
}

@end
