//
//  BSReuqest.m
//  testAFNetWorking
//
//  Created by ucredit-XiaoYang on 16/4/5.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "BSRequest.h"
#import "BSAPIClient.h"
#import "BSNetworkPrivate.h"
#import "ResponseModel.h"


#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_QoS_Available 1140.11
#else
#define NSFoundationVersionNumber_With_QoS_Available NSFoundationVersionNumber_iOS_8_0
#endif


static dispatch_queue_t bsrequest_cache_writing_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_With_QoS_Available) {
            attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        }
        queue = dispatch_queue_create("com.bskit.bsrequest.caching", attr);
    });
    
    return queue;
}


@implementation BSRequest

#pragma mark - AFSession Rquest

- (void)start {
    if (self.ignoreCache) {
        [self startWithoutCache];
        return;
    }
    
    if ([self requestMethod] == BSRequestMethodDownload || [self requestMethod] == BSRequestMethodUpload) {
        [self startWithoutCache];
        return;
    }
    
    if (![super loadCacheSuccess]) {
        [self startWithoutCache];
        return;
    }
    
    self.dataFromCache = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestCompletePreprocessor];
        BSRequest *strongSelf = self;
        if (strongSelf.successCompletionBlock) {
            strongSelf.successCompletionBlock(strongSelf);
        }
        [strongSelf clearCompletionBlock];
    });
}

- (void)requestCompletePreprocessor {
    if (self.writeCacheAsynchronously) {
        dispatch_async(bsrequest_cache_writing_queue(), ^{
            [self saveResponseDataToCacheFile:[super responseData]];
        });
    } else {
        [self saveResponseDataToCacheFile:[super responseData]];
    }
}


- (void)setCompletionBlockWithSuccess:(BSRequestCompletionBlock)success
                              failure:(BSRequestCompletionBlock)failure {
    
    __weak typeof(self) weakSelf = self;
    self.successCompletionBlock = ^(BSRequest *request) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf filterSuccessRequestCompletion:request]) {
            success(request);
        }
    };
    
    self.failureCompletionBlock = ^(BSRequest *request) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf filterFailureRequestCompletion:request]) {
            failure(request);
        }
    };
    
//    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}


- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}


- (void)startWithCompletionSuccess:(BSRequestCompletionBlock)success
                           failure:(BSRequestCompletionBlock)failure {
    
    [self setCompletionBlockWithSuccess:success
                                failure:failure];
    [self start];
    
}

#pragma mark - 
- (void)addRequest {
    [[BSAPIClient sharedClient] addRequest:self];
}

- (void)startWithoutCache {
    [self clearCacheVariables];
    [self addRequest];
}


#pragma mark - override
- (id)responseJOSNObject {
    if (self.cacheJSON) {
        return self.cacheJSON;
    }
    return [super responseJOSNObject];
}

- (NSData *)responseData {
    if (self.cacheData) {
        return self.cacheData;
    }
    return [super responseData];
}

- (id)responseObject {
    if (self.cacheJSON) {
        return self.cacheJSON;
    }
    if (self.cacheData) {
        return self.cacheData;
    }
    return [super responseObject];
}

- (ResponseModel *)responseModel {
    if (self.cacheJSON) {
        return [BSNetworkPrivate responseModel:self.cacheJSON request:self];
    }
    return _responseModel;
}

- (BOOL)filterSuccessRequestCompletion:(__kindof BSRequest *)request {
    return YES;
}

- (BOOL)filterFailureRequestCompletion:(__kindof BSRequest *)request {
    return YES;
}

@end
