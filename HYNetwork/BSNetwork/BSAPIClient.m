//
//  BSAPIClient.m
//  testAFNetWorking
//
//  Created by XiaoYang on 16/1/29.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "BSAPIClient.h"
#import "BSRequest.h"
#import "BSDownloadRequest.h"
#import "BSNetworkConfig.h"
#import "BSNetworkPrivate.h"
#import "ResponseModel.h"
#import <objc/runtime.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#else
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#endif

// 消息通知
NSString *const BSAPIClientRequestFailureNotification = @"com.XiaoYang.BSAPIClientRequestFailureNotification";

// runtime key
static const void *kBSRequestKey = @"com.XiaoYang.BSRequestKey";



@implementation BSAPIClient {
    AFHTTPSessionManager *_manager;
    BSNetworkConfig *_config;
}


+ (instancetype)sharedClient {
    static BSAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BSAPIClient alloc] init];
    });
    return _sharedClient;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
        _config = [BSNetworkConfig sharedInstance];
        _manager.securityPolicy = _config.securityPolicy;
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

// 设置http HeaderField
- (AFHTTPRequestSerializer *)pr_setRequestSerializer:(BSBasicsRequest *)request {
    switch (request.requestSerializerType) {
        case BSRequestSerializerTypeHTTP:
            return [AFHTTPRequestSerializer serializer];
            break;
        case BSRequestSerializerTypeJSON:
            return [AFJSONRequestSerializer serializer];
            break;
    }
}

- (AFHTTPResponseSerializer *)pr_setResponseSerializer:(BSBasicsRequest *)request {
    switch (request.responseSerializerType) {
        case BSResponseSerializerTypeHTTP:
            return [AFHTTPResponseSerializer serializer];
            break;
        case BSResponseSerializerTypeJSON:
            return [AFJSONResponseSerializer serializer];
            break;
    }
}

- (void)setUpHTTPHeaderField:(BSBasicsRequest *)request {
    if (request.requestHTTPHeaderField && [request.requestHTTPHeaderField count] != 0) {
        [request.requestHTTPHeaderField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
}


#pragma mark - start request

- (void)addRequest:(BSBasicsRequest *)request {
    _manager.requestSerializer  = [self pr_setRequestSerializer:request];
    [self setUpHTTPHeaderField:request];
    _manager.responseSerializer = [self pr_setResponseSerializer:request];
    
    _manager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    if ([request isKindOfClass:[BSRequest class]]) {
        [self pr_addRequest:(BSRequest *)request];
    }
    else if ([request isKindOfClass:[BSDownloadRequest  class]]){
        [self pr_addDownloadRequest:(BSDownloadRequest *)request];
    }
}


- (void)pr_addRequest:(BSRequest *)request {
    NSString *requestURL = [BSNetworkPrivate buildRequestUrl:request];
    
    BSRequestProgress progress = [request progressBlock];
    
    if ([request requestMethod] == BSRequestMethodGet) {
        id parameters = [BSNetworkPrivate currentArgument:request];
        request.currentURLSessionDataTask = [_manager GET:requestURL
                                           parameters:parameters
                                             progress:progress
                                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                  
                                                  [self pr_successRequest:request response:responseObject sessionTask:task];
                                                  
                                              }
                                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                  
                                                  [self pr_failureRequest:request error:error sessionTask:task];
                                                  
                                              }];
        
    }
    else if ([request requestMethod] == BSRequestMethodPost) {
        id parameters = [BSNetworkPrivate currentArgument:request];
        
        request.currentURLSessionDataTask = [_manager POST:requestURL
                                            parameters:parameters
                                              progress:progress
                                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                   
                                                   [self pr_successRequest:request response:responseObject sessionTask:task];
                                                   
                                               }
                                               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                   
                                                   [self pr_failureRequest:request error:error sessionTask:task];
                                                   
                                               }];
        
    }
    else if ([request requestMethod] == BSRequestMethodUpload) {
        id parameters = [BSNetworkPrivate currentArgument:request];
        
        BSConstructingBlock constructingBlock = [request constructingMultipartBlock];
        request.currentURLSessionDataTask = [_manager POST:requestURL
                                            parameters:parameters
                             constructingBodyWithBlock:constructingBlock
                                              progress:progress
                                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                   
                                                   [self pr_successRequest:request response:responseObject sessionTask:task];
                                                   
                                               }
                                               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                   
                                                   [self pr_failureRequest:request error:error sessionTask:task];
                                                   
                                               }];
    }
    
}


#pragma mark - start download request
- (void)pr_addDownloadRequest:(BSDownloadRequest *)request {
    NSString *requestURL = [BSNetworkPrivate buildRequestUrl:request];
    BSRequestProgress progress = [request progressBlock];
    BSDownloadDestinationBlock destination = [request downloadDestinationBlock];
    
    if (request.isDownloadTaskCompleted) {
        [self downloadSuccess:request.downloadFilePath withRequest:request];
        return;
    }
    
    if (!request.isOpenResumeDownload) {
        [self addDownloadWithRequest:request
                          requestURL:requestURL
                            progress:progress
                         destination:destination];
        return;
    }
    
    NSData *resumeData = request.currentResumeData ?: [request getDownloadResumeData];
    if (resumeData) {
        
        [self addDownloadWithRequest:request
                          resumeData:resumeData
                            progress:progress
                         destination:destination];
        
    } else {
        
        [self addDownloadWithRequest:request
                          requestURL:requestURL
                            progress:progress
                         destination:destination];
        
    }
    
    [self addDownloadWithRequestDelegate:request];
    
}

- (void)addDownloadWithRequest:(BSDownloadRequest *)request
                    requestURL:(NSString *)requestURL
                      progress:(BSRequestProgress)progress
                   destination:(BSDownloadDestinationBlock)destination {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL relativeToURL:_manager.baseURL]];
    id parameters = [BSNetworkPrivate currentArgument:request];
    NSError *error;
    NSURLRequest *serializerRequest = [_manager.requestSerializer requestBySerializingRequest:urlRequest withParameters:parameters error:&error];
    if (error) {
        [BSNetworkPrivate throwExceptiont:@"request By Serializing Requesta failed, reason = %@", error];
    }
    
    request.currentURLSessionDownloadTask =
    [_manager downloadTaskWithRequest:serializerRequest
                         progress:progress
                      destination:destination
                completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    
                    NSURLSessionDownloadTask *task = [_manager.session downloadTaskWithRequest:serializerRequest];
                    [self pr_downloadRequest:request
                                    filePath:filePath
                                       error:error
                                 sessionTask:task];
                    
                }];
    [request.currentURLSessionDownloadTask resume];
}

- (void)addDownloadWithRequest:(BSDownloadRequest *)request
                    resumeData:(NSData *)resumeData
                      progress:(BSRequestProgress)progress
                   destination:(BSDownloadDestinationBlock)destination {
    request.currentURLSessionDownloadTask =
    [_manager downloadTaskWithResumeData:resumeData
                            progress:progress
                         destination:destination
                   completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                       
                       NSURLSessionDownloadTask *task = [_manager.session downloadTaskWithResumeData:resumeData];
                       [self pr_downloadRequest:request
                                       filePath:filePath
                                          error:error
                                    sessionTask:task];
                   }];
    [request.currentURLSessionDownloadTask resume];
}

- (void)addDownloadWithRequestDelegate:(BSDownloadRequest *)request {
    __block float lastTotalWriten = request.lastTotalWriten;
    [_manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        if (totalBytesWritten - lastTotalWriten > totalBytesExpectedToWrite/10) {
            request.lastTotalWriten = totalBytesWritten;
            __weak typeof(request) weakRequest = request;
            [request setDownloadTaskSuspend:^(NSData * _Nullable resumeData) {
                __strong typeof(weakRequest) strongRequest = weakRequest;
                if (resumeData) {
                    strongRequest.currentURLSessionDownloadTask = [session downloadTaskWithResumeData:resumeData];
                    strongRequest.currentResumeData = resumeData;
                }
            }];
        }
        
    }];
}


#pragma mark - request callback analysis
- (void)pr_successRequest:(BSRequest *)request
                 response:(id)responseObject
              sessionTask:(NSURLSessionDataTask *)task {
    BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
    if (!currentRequest) {
        objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self requestSuccess:responseObject withSessionTask:task];
}


- (void)pr_failureRequest:(BSRequest *)request
                    error:(NSError *)error
              sessionTask:(NSURLSessionDataTask *)task {
    BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
    if (!currentRequest) {
        objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self requestFailure:error withSessionTask:task];
}


- (void)requestSuccess:(id)responseObject withSessionTask:(NSURLSessionDataTask *)task {
    NSString *requestCode = _config.responseParams[REQUEST_CODE];
    
    BSRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    if (!request) return;
    
    NSError * __autoreleasing serializationError = nil;
    
    request.responseObject = responseObject;
    switch (request.responseSerializerType) {
        case BSResponseSerializerTypeHTTP:
            request.responseData = responseObject;
            break;
        case BSResponseSerializerTypeJSON:
            request.responseJOSNObject = responseObject;
            request.responseData = [NSJSONSerialization dataWithJSONObject:request.responseJOSNObject options:NSJSONWritingPrettyPrinted error:&serializationError];
            break;
    }
    
    if (serializationError) {
        [self requestFailure:serializationError withSessionTask:task];
        return;
    }
    
    @autoreleasepool {
        [request requestCompletePreprocessor];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.responseJOSNObject) {
            id response = [BSNetworkPrivate responseModel:request.responseJOSNObject request:request];
            if ([response isKindOfClass:[ResponseModel class]]) {
                request.responseModel = (ResponseModel *)response;
            } else {
                request.responseModel = nil;
            }
        }
        
        if ([responseObject[requestCode] isEqualToNumber:_config.successCodeStatus]) {
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request);
            }
        }
        else {
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            
            request.error = [NSError errorWithDomain:BSRequestErrorDomain code:-10010 userInfo:@{NSLocalizedDescriptionKey:@"HTTP请求返回成功，但是code码不等于successCodeStatus"}];
            NSDictionary *dict = @{@"userInfo" : request};
            [[NSNotificationCenter defaultCenter] postNotificationName:BSAPIClientRequestFailureNotification object:nil userInfo:dict];
        }
        
        [request clearCompletionBlock];
    });
}


- (void)requestFailure:(NSError *)error withSessionTask:(NSURLSessionDataTask *)task{
    
    BSRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    if (!request) return;
    
    request.error = error;
    ResponseModel *response =(ResponseModel *)[BSNetworkPrivate responseModel:error];
    request.responseModel = response;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request);
        }
        
        NSDictionary *dict = @{@"userInfo" : request};
        [[NSNotificationCenter defaultCenter] postNotificationName:BSAPIClientRequestFailureNotification object:nil userInfo:dict];
        
        [request clearCompletionBlock];
    });
}


#pragma mark - download callback analysis
- (void)pr_downloadRequest:(BSDownloadRequest *)request
                  filePath:(NSURL *)filePath
                     error:(NSError *)error
               sessionTask:(NSURLSessionDownloadTask *)task {
    
    BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
    if (!currentRequest) {
        objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (error) {
        if (error.code == -999) {
            [request start];
        } else {
            [self downloadFailure:error withSessionTask:task];
        }
    }
    else {
        [self downloadSuccess:filePath withSessionTask:task];
    }
    
}


- (void)downloadSuccess:(NSURL *)filePath withSessionTask:(NSURLSessionDownloadTask *)task {
    BSDownloadRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    if (![request modifyContentWithName:filePath.lastPathComponent]) {
        NSLog(@"修改信息失败");
    }
    [self downloadSuccess:filePath withRequest:request];
}

- (void)downloadSuccess:(NSURL *)filePath withRequest:(BSDownloadRequest *)request {
    ResponseModel *model = [[ResponseModel alloc] init];
    model.code = _config.successCodeStatus;
    model.message = @"download is success";
    model.timestamp = @([[NSDate date] timeIntervalSince1970]);
    model.data = filePath;
    
    request.responseModel = model;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.successCompletionBlock) {
            request.successCompletionBlock(request);
        }
        
        [request clearCompletionBlock];
    });
}

- (void)downloadFailure:(NSError *)error withSessionTask:(NSURLSessionDownloadTask *)task {
    BSRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    
    request.error = error;
    ResponseModel *response =(ResponseModel *)[BSNetworkPrivate responseModel:error];
    request.responseModel = response;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request);
        }
        
        [request clearCompletionBlock];
    });
}


@end
