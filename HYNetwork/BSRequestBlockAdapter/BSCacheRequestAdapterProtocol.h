//
//  BSCacheRequestAdapterProtocol.h
//  void_network
//
//  Created by void on 2018/8/24.
//  Copyright © 2018年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BSCacheRequestAdapterProtocol <NSObject>

/// 缓存时间
@property (nonatomic, assign) NSTimeInterval cacheTimeInSeconds;

/// 是否异步缓存
@property (nonatomic, assign) BOOL writeCacheAsynchronously;

@end

