//
//  BSBlockBasicsRequest.m
//  void_network
//
//  Created by void on 2018/8/23.
//  Copyright © 2018年 XiaoYang. All rights reserved.
//

#import "BSBlockBasicsRequest.h"

@implementation BSBlockBasicsRequest

@synthesize api;
@synthesize constructingMultipartBlock;
@synthesize headerField;
@synthesize method;
@synthesize params;
@synthesize requestSerializer;
@synthesize modelClass;
@synthesize requestSerializerType;
@synthesize responseSerializer;
@synthesize responseSerializerType;
@synthesize timeoutInterval;
@synthesize progressBlock;


- (instancetype)init {
    self = [super init];
    if (self) {
        writeCacheAsynchronously = YES;
    }
    return self;
}


- (NSString *)requestUrl {
    return api;
}

- (id)requestArgument {
    return params;
}


- (id)requestHTTPHeaderField {
    return headerField;
}

- (NSTimeInterval)requestTimeoutInterval {
    return timeoutInterval > 0 ? timeoutInterval : 30;
}

- (BSRequestMethod)requestMethod {
    return method;
}

- (BSConstructingBlock)constructingMultipartBlock {
    if ([self requestMethod] == BSRequestMethodUpload) {
        return constructingMultipartBlock;
    }
    return nil;
}

- (BSRequestProgress)progressBlock {
    return progressBlock;
}

- (Class)modelClass {
    return modelClass;
}

- (BSRequestSerializerType)requestSerializerType {
    return requestSerializerType;
}

- (AFHTTPRequestSerializer *)requestSerializer {
    return requestSerializer;
}

- (BSResponseSerializerType)responseSerializerType {
    return responseSerializerType;
}

- (AFHTTPResponseSerializer *)responseSerializer {
    return responseSerializer;
}


#pragma mark - 缓存相关

@synthesize writeCacheAsynchronously;
@synthesize cacheTimeInSeconds;

- (NSTimeInterval)cacheTimeInSeconds {
    return cacheTimeInSeconds > 0 ? cacheTimeInSeconds : -1;
}

- (BOOL)writeCacheAsynchronously {
    return writeCacheAsynchronously;
}


#pragma mark - 下载相关

@synthesize openResumeDownload;
@synthesize downloadDestinationBlock;

- (BOOL)isOpenResumeDownload {
    return openResumeDownload;
}

- (BSDownloadDestinationBlock)downloadDestinationBlock {
    if ([self requestMethod] == BSRequestMethodDownload) {
        return downloadDestinationBlock;
    }
    return nil;
}


@end
