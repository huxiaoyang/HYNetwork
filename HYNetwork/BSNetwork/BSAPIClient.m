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


@interface BSAPIClient ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end


@implementation BSAPIClient {
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
        _config = [BSNetworkConfig sharedInstance];
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_config.baseURL]];
        _manager.securityPolicy = _config.securityPolicy;
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        if (_config.secretCodeWithP12) [self testAndVerifyP12];
    }
    return self;
}


- (AFHTTPRequestSerializer *)pr_setRequestSerializer:(BSBasicsRequest *)request {
    switch (request.requestSerializerType) {
        case BSRequestSerializerTypeHTTP:
            return request.requestSerializer ?: [AFHTTPRequestSerializer serializer];
        case BSRequestSerializerTypeJSON:
            return request.requestSerializer ?: [AFJSONRequestSerializer serializer];
    }
}

- (AFHTTPResponseSerializer *)pr_setResponseSerializer:(BSBasicsRequest *)request {
    switch (request.responseSerializerType) {
        case BSResponseSerializerTypeHTTP:
            return request.responseSerializer ?: [AFHTTPResponseSerializer serializer];
        case BSResponseSerializerTypeJSON:
            return request.responseSerializer ?: [AFJSONResponseSerializer serializer];
    }
}

- (void)setUpHTTPHeaderField:(BSBasicsRequest *)request {
    if (!request.requestHTTPHeaderField || [request.requestHTTPHeaderField count] == 0) return;
    [request.requestHTTPHeaderField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [_manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

- (void)testAndVerifyP12 {
    
    __weak typeof(self)weakSelf = self;
    
    [_manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
        
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __autoreleasing NSURLCredential *credential =nil;
        
        if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
           
            if([weakSelf.manager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if(credential) {
                    disposition =NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition =NSURLSessionAuthChallengePerformDefaultHandling;
                }
                
            } else {
                
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            
            }
            
        } else {
            // client authentication
            SecIdentityRef identity = NULL;
            SecTrustRef trust = NULL;
            NSBundle *bundle = [NSBundle bundleForClass:[weakSelf class]];
            NSArray *paths = [bundle pathsForResourcesOfType:@"p12" inDirectory:@"."];
            if (!paths || !paths.count || paths.count > 1) {
                
                [BSNetworkPrivate throwExceptiont:@"请检查mianBundle中是否有切只有一个p12文件"];
                
            } else {
                
                NSString *p12 = paths.firstObject;
                NSFileManager *fileManager =[NSFileManager defaultManager];
                
                if(![fileManager fileExistsAtPath:p12]) {
                    
                    NSLog(@"client.p12:not exist");
                    
                } else {
                    
                    NSData *PKCS12Data = [NSData dataWithContentsOfFile:p12];
                    
                    if ([BSNetworkPrivate extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data]) {
                        
                        SecCertificateRef certificate = NULL;
                        SecIdentityCopyCertificate(identity, &certificate);
                        const void*certs[] = {certificate};
                        CFArrayRef certArray =CFArrayCreate(kCFAllocatorDefault, certs,1,NULL);
                        credential =[NSURLCredential credentialWithIdentity:identity certificates:(__bridge  NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
                        disposition =NSURLSessionAuthChallengeUseCredential;
                        
                    }
                    
                }
                
            }
            
        }
        
        *_credential = credential;
        return disposition;
        
    }];
    
}

#pragma mark - start request

- (void)addRequest:(BSRequest *)request {
    _manager.requestSerializer  = [self pr_setRequestSerializer:request];
    [self setUpHTTPHeaderField:request];
    _manager.responseSerializer = [self pr_setResponseSerializer:request];
    
    _manager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    [self pr_addRequest:(BSRequest *)request];
}


- (void)pr_addRequest:(BSRequest *)request {
    NSString *requestURL = [BSNetworkPrivate buildRequestUrl:request];
    
    BSRequestProgress progress = [request progressBlock];
    
    id parameters = request.requestArgument;

    if (_config.parametersFilter) {
        parameters = [_config.parametersFilter filterParameter:parameters request:request];
    }
    [request setValue:parameters forKey:@"_parameters"];
    
    if ([request requestMethod] == BSRequestMethodGet) {
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
    else if ([request requestMethod] == BSRequestMethodDownload) {
        
        BSDownloadDestinationBlock destination = [request downloadDestinationBlock];
        if (request.downloadTaskCompleted) {
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
    
}


#pragma mark - download request

- (void)addDownloadWithRequest:(BSRequest *)request
                    requestURL:(NSString *)requestURL
                      progress:(BSRequestProgress)progress
                   destination:(BSDownloadDestinationBlock)destination {
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL relativeToURL:_manager.baseURL]];
    
    id parameters = request.requestArgument;
    
    if (_config.parametersFilter) {
        parameters = [_config.parametersFilter filterParameter:parameters request:request];
    }
    
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

- (void)addDownloadWithRequest:(BSRequest *)request
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

- (void)addDownloadWithRequestDelegate:(BSRequest *)request {
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
//    NSString *requestCode = _config.responseParams[REQUEST_CODE];
    
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
            id response = [_config.fetchResponseModelFilter responseModel:request.responseJOSNObject request:request];
            if ([response isKindOfClass:[ResponseModel class]]) {
                request.responseModel = (ResponseModel *)response;
            } else {
                request.responseModel = nil;
            }
        }
        
        if (![responseObject isKindOfClass:NSDictionary.class]) {
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            
            request.error = [NSError errorWithDomain:BSRequestErrorDomain code:-90010 userInfo:@{NSLocalizedDescriptionKey:@"HTTP请求返回成功，但是无法解析response"}];
            NSDictionary *dict = @{@"userInfo" : request};
            [[NSNotificationCenter defaultCenter] postNotificationName:BSAPIClientRequestFailureNotification object:nil userInfo:dict];
        }
        
        __block BOOL _responseCodeIsSuccess = NO;
        NSDictionary *responseCodeDic = _config.successCodeDic;
        [responseCodeDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
           
            if ([((NSDictionary *)responseObject).allKeys containsObject:key]) {
                if ([responseObject[key] isKindOfClass:NSNumber.class]) {
                    _responseCodeIsSuccess = [((NSNumber *)responseObject[key]).stringValue isEqualToString:obj];
                }
                if ([responseObject[key] isKindOfClass:NSString.class]) {
                    _responseCodeIsSuccess = [responseObject[key] isEqualToString:obj];
                }
                *stop = YES;
            }
            
        }];
        
        if (!_responseCodeIsSuccess) {
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            
            request.error = [NSError errorWithDomain:BSRequestErrorDomain code:-90001 userInfo:@{NSLocalizedDescriptionKey:@"HTTP请求返回成功，但是code码不等于successCodeStatus"}];
            NSDictionary *dict = @{@"userInfo" : request};
            [[NSNotificationCenter defaultCenter] postNotificationName:BSAPIClientRequestFailureNotification object:nil userInfo:dict];
        }
        
        if (request.successCompletionBlock) {
            request.successCompletionBlock(request);
        }
        
        [request clearCompletionBlock];
    });
}


- (void)requestFailure:(NSError *)error withSessionTask:(NSURLSessionDataTask *)task{
    
    BSRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    if (!request) return;
    
    request.error = error;
    ResponseModel *response =(ResponseModel *)[_config.fetchResponseModelFilter responseModel:error];
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
- (void)pr_downloadRequest:(BSRequest *)request
                  filePath:(NSURL *)filePath
                     error:(NSError *)error
               sessionTask:(NSURLSessionDownloadTask *)task {
    
    BSRequest *currentRequest = objc_getAssociatedObject(task, &kBSRequestKey);
    if (!currentRequest) {
        objc_setAssociatedObject(task, &kBSRequestKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (error) {
        if (error.code == -999) {
            [request addRequest];
        } else {
            [self downloadFailure:error withSessionTask:task];
        }
    }
    else {
        [self downloadSuccess:filePath withSessionTask:task];
    }
    
}


- (void)downloadSuccess:(NSURL *)filePath withSessionTask:(NSURLSessionDownloadTask *)task {
    BSRequest *request = objc_getAssociatedObject(task, &kBSRequestKey);
    if (![request modifyContentWithName:filePath.lastPathComponent]) {
        NSLog(@"修改信息失败");
    }
    [self downloadSuccess:filePath withRequest:request];
}

- (void)downloadSuccess:(NSURL *)filePath withRequest:(BSRequest *)request {
    ResponseModel *model = [[ResponseModel alloc] init];
    model.code = BSResponseSuccessCode;
    model.message = @"download is success";
    model.timestamp = @([[NSDate date] timeIntervalSince1970]).stringValue;
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
    ResponseModel *response =(ResponseModel *)[_config.fetchResponseModelFilter responseModel:error];
    request.responseModel = response;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request);
        }
        
        [request clearCompletionBlock];
    });
}


@end
