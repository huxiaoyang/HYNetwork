//
//  BSAPIClient.m
//  testAFNetWorking
//
//  Created by XiaoYang on 16/1/29.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "BSAPIClient.h"
#import "BSRequest.h"
#import "BSNetworkConfig.h"
#import "BSNetworkPrivate.h"
#import "ResponseModel.h"
#import <objc/runtime.h>
#import "AFNetworkActivityIndicatorManager.h"

// 消息通知
NSString *const BSAPIClientRequestFailureNotification = @"com.XiaoYang.BSAPIClientRequestFailureNotification";

// runtime key
static const void *kBSRequestKey = @"com.XiaoYang.BSRequestKey";



@implementation BSAPIClient {
    BSNetworkConfig *_config;
}


+ (instancetype)sharedClient {
    static BSAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [BSAPIClient manager];
    });
    return _sharedClient;
}


- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        _config = [BSNetworkConfig sharedInstance];
        self.securityPolicy = _config.securityPolicy;
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

// 设置http HeaderField
- (AFHTTPRequestSerializer *)pr_setRequestSerializer:(BSRequest *)request {
    switch (request.requestSerializerType) {
        case BSRequestSerializerTypeHTTP:
            return [AFHTTPRequestSerializer serializer];
            break;
        case BSRequestSerializerTypeJSON:
            return [AFJSONRequestSerializer serializer];
            break;
    }
}

- (AFHTTPResponseSerializer *)pr_setResponseSerializer:(BSRequest *)request {
    switch (request.responseSerializerType) {
        case BSResponseSerializerTypeHTTP:
            return [AFHTTPResponseSerializer serializer];
            break;
        case BSResponseSerializerTypeJSON:
            return [AFJSONResponseSerializer serializer];
            break;
    }
}

- (void)setUpHTTPHeaderField:(BSRequest *)request {
    if (request.requestHTTPHeaderField && [request.requestHTTPHeaderField count] != 0) {
        [request.requestHTTPHeaderField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
}


#pragma mark - start request

- (void)addRequest:(BSRequest *)request {
    
    self.requestSerializer  = [self pr_setRequestSerializer:request];
    [self setUpHTTPHeaderField:request];
    self.responseSerializer = [self pr_setResponseSerializer:request];
    
    self.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    NSString *requestURL = [BSNetworkPrivate buildRequestUrl:request];
    
    BSRequestProgress progress = [request progressBlock];
    
    if ([request requestMethod] == BSRequestMethodGet) {    
        id parameters = [BSNetworkPrivate currentArgument:request];
        request.currentURLSessionDataTask = [self GET:requestURL
                                           parameters:parameters
                                             progress:progress
                                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                  
                                                  BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
                                                  if (!currentRequest) {
                                                      objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                  }
                                                  
                                                  [self requestSuccess:responseObject withSessionTask:task];
                                                  
                                              }
                                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                  
                                                  BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
                                                  if (!currentRequest) {
                                                      objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                  }
                                                  
                                                  [self requestFailure:error withSessionTask:task];
                                                  
                                              }];
        
    }
    else if ([request requestMethod] == BSRequestMethodPost) {
        id parameters = [BSNetworkPrivate currentArgument:request];
        
        request.currentURLSessionDataTask = [self POST:requestURL
                                            parameters:parameters
                                              progress:progress
                                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                   
                                                   BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
                                                   if (!currentRequest) {
                                                       objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                   }
                                                   
                                                   [self requestSuccess:responseObject withSessionTask:task];
                                                   
                                               }
                                               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                   
                                                   BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
                                                   if (!currentRequest) {
                                                       objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                   }
                                                   
                                                   [self requestFailure:error withSessionTask:task];
                                                   
                                               }];
        
    }
    else if ([request requestMethod] == BSRequestMethodUpload) {
        id parameters = [BSNetworkPrivate currentArgument:request];

        BSConstructingBlock constructingBlock = [request constructingMultipartBlock];
        request.currentURLSessionDataTask = [self POST:requestURL
                                            parameters:parameters
                             constructingBodyWithBlock:constructingBlock
                                              progress:progress
                                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                   
                                                   BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
                                                   if (!currentRequest) {
                                                       objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                   }
                                                   
                                                   [self requestSuccess:responseObject withSessionTask:task];
                                                   
                                               }
                                               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                   
                                                   BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
                                                   if (!currentRequest) {
                                                       objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                   }
                                                   
                                                   [self requestFailure:error withSessionTask:task];
                                                   
                                               }];
    }
    else if ([request requestMethod] == BSRequestMethodDownload) {
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL relativeToURL:self.baseURL]];
        
        BSDownloadDestinationBlock destination = [request downloadDestinationBlock];
        request.currentURLSessionDownloadTask = [self downloadTaskWithRequest:urlRequest
                                                                     progress:progress
                                                                  destination:destination
                                                            completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                
                                                                NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:urlRequest];
                                                                BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
                                                                if (!currentRequest) {
                                                                    objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                                }
                                                                
                                                                if (error) {
                                                                    [self downloadFailure:error withSessionTask:task];
                                                                }
                                                                else {
                                                                    [self downloadSuccess:filePath withSessionTask:task];
                                                                }
                                                                
                                                            }];
        [request.currentURLSessionDownloadTask resume];
    }
    
}


#pragma mark - request callback analysis
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
- (void)downloadSuccess:(NSURL *)filePath withSessionTask:(NSURLSessionDownloadTask *)task {
    BSRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    
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
