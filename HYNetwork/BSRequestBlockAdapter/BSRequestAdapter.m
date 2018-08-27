//
//  BSRequestAdapter.m
//  void_network
//
//  Created by void on 2018/8/23.
//  Copyright © 2018年 XiaoYang. All rights reserved.
//

#import "BSRequestAdapter.h"


@interface BSRequestAdapter ()

@property (nonatomic, strong) BSBlockBasicsRequest *request;

@property (nonatomic, copy) BSRequestCompletionBlock successHandle;
@property (nonatomic, copy) BSRequestCompletionBlock failureHandle;
@property (nonatomic, copy) BSRequestCompletionBlock alwaysHandle;

@end


@implementation BSRequestAdapter

- (instancetype)initWithAPI:(NSString *)api {
    self = [super init];
    if (self) {
        _request = [[BSBlockBasicsRequest alloc] init];
        _request.api = api;
    }
    return self;
}

#pragma mark - 请求方式

+ (BSRequestAdapter *(^)(NSString *))get {
    return ^(NSString *api){
        BSRequestAdapter *adapter = [[BSRequestAdapter alloc] initWithAPI:api];
        adapter.request.method = BSRequestMethodGet;
        return adapter;
    };
}

+ (BSRequestAdapter *(^)(NSString *))post {
    return ^(NSString *api){
        BSRequestAdapter *adapter = [[BSRequestAdapter alloc] initWithAPI:api];
        adapter.request.method = BSRequestMethodPost;
        return adapter;
    };
}

+ (BSRequestAdapter *(^)(NSString *))upload {
    return ^(NSString *api){
        BSRequestAdapter *adapter = [[BSRequestAdapter alloc] initWithAPI:api];
        adapter.request.method = BSRequestMethodUpload;
        return adapter;
    };
}

+ (BSRequestAdapter *(^)(NSString *))download {
    return ^(NSString *api){
        BSRequestAdapter *adapter = [[BSRequestAdapter alloc] initWithAPI:api];
        adapter.request.method = BSRequestMethodDownload;
        return adapter;
    };
}


#pragma mark - body参数 / head参数

- (BSRequestAdapter *(^)(NSDictionary *))headerField {
    return ^(NSDictionary *dict) {
        self.request.headerField = dict;
        return self;
    };
}

- (BSRequestAdapter *(^)(NSDictionary *))params {
    return ^(NSDictionary *dict) {
        self.request.params = dict;
        return self;
    };
}


#pragma mark -  请求超时时间

- (BSRequestAdapter *(^)(NSTimeInterval))timeoutInterval {
    return ^(NSTimeInterval time) {
        if (time > 0) {
            self.request.timeoutInterval = time;
        }
        return self;
    };
}


#pragma mark - 上传文件时 Multipart 回调

- (BSRequestAdapter *(^)(BSConstructingBlock))constructingMultipartBlock{
    return ^(BSConstructingBlock block) {
        if (block) {
            self.request.constructingMultipartBlock = block;
        }
        return self;
    };
}


#pragma mark - 请求进度回调

- (BSRequestAdapter *(^)(BSRequestProgress))progressBlock {
    return ^(BSRequestProgress block) {
        if (block) {
            self.request.progressBlock = block;
        }
        return self;
    };
}


#pragma mark - 解析model class

- (BSRequestAdapter *(^)(Class))modelClass {
    return ^(Class class) {
        self.request.modelClass = class;
        return self;
    };
}


#pragma mark - 缓存

- (BSRequestAdapter *(^)(BOOL))ignoreCache {
    return ^(BOOL ignore) {
        self.request.ignoreCache = ignore;
        return self;
    };
}

- (BSRequestAdapter *(^)(BOOL))writeCacheAsynchronously {
    return ^(BOOL async) {
        self.request.writeCacheAsynchronously = async;
        return self;
    };
}

- (BSRequestAdapter *(^)(NSTimeInterval))cacheTimeInSeconds {
    return ^(NSTimeInterval time) {
        self.request.cacheTimeInSeconds = time;
        return self;
    };
}


#pragma mark - 下载

- (BSRequestAdapter *(^)(BOOL))openResumeDownload {
    return ^(BOOL open) {
        self.request.openResumeDownload = open;
        return self;
    };
}

- (BSRequestAdapter *(^)(BSDownloadDestinationBlock))downloadDestinationBlock {
    return ^(BSDownloadDestinationBlock block) {
        if (block) {
            self.request.downloadDestinationBlock = block;
        }
        return self;
    };
}


#pragma mark - request / response Serializer

- (BSRequestAdapter *(^)(BSRequestSerializerType))requestSerializerType {
    return ^(BSRequestSerializerType type) {
        self.request.requestSerializerType = type;
        return self;
    };
}
- (BSRequestAdapter *(^)(AFHTTPRequestSerializer *))requestSerializer {
    return ^(AFHTTPRequestSerializer *serializer) {
        self.request.requestSerializer = serializer;
        return self;
    };
}
- (BSRequestAdapter *(^)(BSResponseSerializerType))responseSerializerType {
    return ^(BSResponseSerializerType type) {
        self.request.responseSerializerType = type;
        return self;
    };
}
- (BSRequestAdapter *(^)(AFHTTPResponseSerializer *))responseSerializer {
    return ^(AFHTTPResponseSerializer *serializer) {
        self.request.responseSerializer = serializer;
        return self;
    };
}


#pragma mark - start request

- (BSRequestAdapter *(^)(void))fetch {
    return ^() {
        [self pr_startRequest];
        return self;
    };
}

- (void)pr_startRequest {
    [self.request startWithCompletionSuccess:^(__kindof BSRequest * _Nullable request) {
        if (self.successHandle) { self.successHandle(request); }
        if (self.alwaysHandle) { self.alwaysHandle(request); }
    } failure:^(__kindof BSRequest * _Nullable request) {
        if (self.failureHandle) { self.failureHandle(request); }
        if (self.alwaysHandle) { self.alwaysHandle(request); }
    }];
}


- (BSRequestAdapter *(^)(BSRequestCompletionBlock))success {
    return ^(BSRequestCompletionBlock block) {
        if (block) {
            self.successHandle = block;
        }
        if (!self.request.currentURLSessionDataTask) {
            [self pr_startRequest];
        }
        return self;
    };
}

- (BSRequestAdapter *(^)(BSRequestCompletionBlock))failure {
    return ^(BSRequestCompletionBlock block) {
        if (block) {
            self.failureHandle = block;
        }
        if (!self.request.currentURLSessionDataTask) {
            [self pr_startRequest];
        }
        return self;
    };
}

- (BSRequestAdapter *(^)(BSRequestCompletionBlock))always {
    return ^(BSRequestCompletionBlock block) {
        if (block) {
            self.alwaysHandle = block;
        }
        if (!self.request.currentURLSessionDataTask) {
            [self pr_startRequest];
        }
        return self;
    };
}


#pragma mark - 请求取消

- (void)cancel {
    [self.request taskCancel];
}

@end
