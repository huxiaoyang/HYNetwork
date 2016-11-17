//
//  BSBasicsRequest.m
//  testAFNetWorking
//
//  Created by XiaoYang on 16/1/29.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "BSBasicsRequest.h"

NSString *const BSRequestErrorDomain = @"com.XiaoYang.requestErrorDomain";


@implementation BSBasicsRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (NSString *)requestUrl {
    return @"";
}


- (id)requestArgument {
    return nil;
}


- (id)globalArgument {
    return nil;
}

- (id)requestHTTPHeaderField {
    return nil;
}


- (NSTimeInterval)requestTimeoutInterval {
    return 30;
}


- (BSRequestMethod)requestMethod {
    return BSRequestMethodGet;
}

- (BSConstructingBlock)constructingMultipartBlock {
    if ([self requestMethod] == BSRequestMethodUpload) {
        NSAssert(NO, @"必须重写Multipart回调");
    }
    return nil;
}

- (BSDownloadDestinationBlock)downloadDestinationBlock {
    if ([self requestMethod] == BSRequestMethodDownload) {
        NSAssert(NO, @"必须重写Destination回调");
    }
    return nil;
}

- (BSRequestProgress)progressBlock {
    return nil;
}

- (Class)modelClass {
    return nil;
}

- (BSRequestSerializerType)requestSerializerType {
    return BSRequestSerializerTypeHTTP;
}

- (BSResponseSerializerType)responseSerializerType {
    return BSResponseSerializerTypeJSON;
}

- (NSURLSessionTaskState)taskState {
    return self.currentURLSessionDataTask.state;
}

- (BOOL)isTaskRunning {
    return self.currentURLSessionDataTask.state == NSURLSessionTaskStateRunning;
}

- (void)taskCancel {
    if ([self isTaskRunning]) {
        [self.currentURLSessionDataTask cancel];
    }
}

- (NSURL *)currentCompleteURL {
    return self.currentURLSessionDataTask.currentRequest.URL;
}

@end
