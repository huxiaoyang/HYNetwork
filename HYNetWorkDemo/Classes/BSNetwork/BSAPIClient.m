//
//  BSAPIClient.m
//  testAFNetWorking
//
//  Created by XiaoYang on 16/1/29.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "BSAPIClient.h"
#import "BSNetworkConfig.h"
#import <objc/runtime.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "YYModel.h"

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
        self.responseSerializer.acceptableContentTypes = nil;
        self.securityPolicy = _config.securityPolicy;
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        if (_config.cacheExpirationInterval > 0) {
            self.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad; // 请求加缓存策略
        }
    }
    return self;
}

// 设置http HeaderField
- (void)setUpHTTPHeaderField:(BSRequest *)request {
    if (request.requestHTTPHeaderField && [request.requestHTTPHeaderField count] != 0) {
        [request.requestHTTPHeaderField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    } else {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
}

// 设置http 请求参数
- (id)currentArgument:(BSRequest *)request {
    
    if (![request globalArgument] || [[request globalArgument] count] == 0) {
        
        id argument = [request requestArgument];
        return argument;
        
    } else {
        
        id argument = [request globalArgument];
        
        NSMutableDictionary *mutableArgument = [argument mutableCopy];
        NSDictionary *dict = (NSDictionary *)[request requestArgument];
        if (dict.count > 0) {
            [mutableArgument addEntriesFromDictionary:dict];
        }
        
        return mutableArgument;
    }
    
}

// 设置http URL
- (NSString *)buildRequestUrl:(BSRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    
    NSString *requestUrl;
    if (_config.baseURL && _config.baseURL.length > 0) {
        requestUrl = [NSString stringWithFormat:@"%@%@", [_config baseURL], detailUrl];
    }
    return [requestUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}


- (void)addRequest:(BSRequest *)request {
    
    [self setUpHTTPHeaderField:request];
    
    self.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    NSString *requestURL = [self buildRequestUrl:request];
    
    BSRequestProgress progress = [request progressBlock];
    
    if ([request requestMethod] == BSRequestMethodGet) {    
        id parameters = [self currentArgument:request];
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
        id parameters = [self currentArgument:request];
        
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
        id parameters = [self currentArgument:request];

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
                                                                
                                                                if (error) {
                                                                    request.error = error;
                                                                    if (request.failureCompletionBlock) {
                                                                        request.failureCompletionBlock(request);
                                                                    }
                                                                }
                                                                else {
                                                                    if (request.successCompletionBlock) {
                                                                        request.successCompletionBlock(request);
                                                                    }
                                                                }
                                                                
                                                            }];
        [request.currentURLSessionDownloadTask resume];
    }
    
}



- (void)requestSuccess:(id)responseObject withSessionTask:(NSURLSessionDataTask *)task {
    NSString *requestCode = _config.responseParams[REQUEST_CODE];
    
    BSRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    
    request.responseJOSNObject = responseObject;
    id response = [self responseModel:responseObject request:request];
    if ([response isKindOfClass:[ResponseModel class]]) {
        request.responseModel = (ResponseModel *)response;
    } else {
        request.responseModel = nil;
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
        
        NSDictionary *dict = @{@"userInfo" : response ?: @""};
        [[NSNotificationCenter defaultCenter] postNotificationName:BSAPIClientRequestFailureNotification object:nil userInfo:dict];
    }
    
    [request clearCompletionBlock];
}


- (void)requestFailure:(NSError *)error withSessionTask:(NSURLSessionDataTask *)task{
    
    BSRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    
    request.error = error;
    ResponseModel *response =(ResponseModel *)[self responseModel:error];
    request.responseModel = response;
    
    if (request.failureCompletionBlock) {
        request.failureCompletionBlock(request);
    }
    
    NSDictionary *dict = @{@"userInfo" : response ?: @""};
    [[NSNotificationCenter defaultCenter] postNotificationName:BSAPIClientRequestFailureNotification object:nil userInfo:dict];
    
    [request clearCompletionBlock];
}


#pragma mark - JSON To Object
- (id)responseModel:(id)responseObject request:(BSRequest *)request {
    
    NSString * requestData = _config.responseParams[REQUEST_DATA];
    NSString * requestCode = _config.responseParams[REQUEST_CODE];
    NSString * requestMsg  = _config.responseParams[REQUEST_MESSAGE];
    NSString * requestTime = _config.responseParams[REQUEST_TIME];
    
    
    if ([responseObject isKindOfClass:[NSArray class]]) {
        ResponseModel *model = [[ResponseModel alloc] init];
        model.code = _config.successCodeStatus;
        model.message = @"request is success";
        model.timestamp = @([[NSDate date] timeIntervalSince1970]);
        model.data = [NSArray yy_modelArrayWithClass:[request modelClass] json:responseObject];
        return model;
    }
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        
        ResponseModel *model = [[ResponseModel alloc] init];
        
        if (![[responseObject allKeys] containsObject:requestData] && ![[responseObject allKeys] containsObject:requestCode]) {
            model.code = _config.successCodeStatus;
            model.message = @"request is success";
            model.timestamp = @([[NSDate date] timeIntervalSince1970]);
            model.data = [NSDictionary yy_modelDictionaryWithClass:[request modelClass] json:responseObject];
            return model;
        }
        
        if ([[responseObject allKeys] containsObject:requestCode]) {
            model.code = responseObject[requestCode];
        }
        
        if ([[responseObject allKeys] containsObject:requestMsg]) {
            model.message = responseObject[requestMsg];
        }
        
        if ([[responseObject allKeys] containsObject:requestTime]) {
            model.timestamp = responseObject[requestTime];
        }
        
        if (![[responseObject allKeys] containsObject:requestData]) {
            model.data = nil;
            return model;
        }
        
        if (![responseObject[requestData] isKindOfClass:[NSDictionary class]] && ![responseObject[requestData] isKindOfClass:[NSArray class]]) {
            model.data = responseObject[requestData];
            return model;
        }
        
        if ([responseObject[requestData] count] == 0 || [responseObject[requestData] isEqual:[NSNull null]]) {
            model.data = nil;
            return model;
        }
        
        if ([responseObject[requestData] isKindOfClass:[NSArray class]]) {
            
            NSArray *items = responseObject[requestData];
            if (items.count == 0) {
                model.data = items;
                return model;
            }
            
            if (![[items firstObject] isKindOfClass:[NSDictionary class]]) {
                model.data = items;
                return model;
            }
            
            model.data = [NSArray yy_modelArrayWithClass:[request modelClass] json:responseObject[requestData]];
            return model;
        }
        
        if ([responseObject[requestData] isKindOfClass:[NSDictionary class]]) {
            model.data = [[request modelClass] yy_modelWithJSON:responseObject[requestData]];
            return model;
        }
        
        return model;
    }
    
    return nil;
}

- (id)responseModel:(NSError *)error {
    ResponseModel *model = [[ResponseModel alloc] init];
    model.code = @(error.code);
    model.timestamp = @([[NSDate date] timeIntervalSince1970]);
#ifdef DEBUG
    model.message = error.localizedDescription;
#else
    switch (error.code) {
        case -1009: // 没有网络
            model.message = @"失去网络链接,请检查您的网络设置!";
            break;
        case -1001: // 请求超时
            model.message = @"网络状态不好,请稍候再试";
            break;
        default:
            model.message = @"网络问题，稍后再试";
            break;
    }
#endif
    
    return model;
}


@end
