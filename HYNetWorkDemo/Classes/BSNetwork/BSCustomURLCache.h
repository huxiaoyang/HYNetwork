//
//  BSCustomURLCache.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/4/29.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, BSCustomURLCachePolicy) {
    BSRequestUseCacheWhenAnytime = 0,   // 不论何时都使用缓存
    BSRequestUseCacheWhenNoNetwork = 1  // 只有失去网络链接时才使用缓存
};


@interface BSCustomURLCache : NSURLCache

+ (instancetype)standardURLCache;

/**
 *  缓存时间
 */
@property (nonatomic, assign) NSTimeInterval cacheExpirationInterval;

/**
 *  缓存策略
 */
@property (nonatomic, assign) BSCustomURLCachePolicy customURLCachePolicy;

@end
