//
//  BSCacheRequest.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/9/23.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import "BSBasicsRequest.h"


@interface BSCacheRequest : BSBasicsRequest

// 忽略缓存 - 默认为NO
@property (nonatomic, assign) BOOL ignoreCache;

// 当前是否有缓存 - YES时当前有缓存
@property (nonatomic, assign, getter=isDataFromCache) BOOL dataFromCache;

// 缓存data，开启缓存时有值
@property (nonatomic, strong, readonly) NSData * _Nullable cacheData;

// 缓存json， responseSerializerType类型是BSResponseSerializerTypeJSON时有值
@property (nonatomic, strong, readonly) id _Nullable cacheJSON;


#pragma mark - Subclass Override
// 缓存时间
- (NSTimeInterval)cacheTimeInSeconds;

// 为缓存分配一个ID - 便于查找
- (long long)cacheVersion;

// 缓存一个额外的敏感数据 - 便于查找
- (nullable id)cacheSensitiveData;

// 是否启用异步缓存 - 默认为YES
- (BOOL)writeCacheAsynchronously;


- (BOOL)loadCacheSuccess;

- (void)clearCacheVariables;

- (void)saveResponseDataToCacheFile:( NSData * _Nullable )data;


@end

