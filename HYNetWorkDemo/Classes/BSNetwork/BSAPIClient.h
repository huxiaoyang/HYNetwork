//
//  BSAPIClient.h
//  testAFNetWorking
//
//  Created by XiaoYang on 16/1/29.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ResponseModel;
@class BSRequest;
@class BSDownloadRequest;


extern NSString *const _Nonnull BSAPIClientRequestFailureNotification;


@interface BSAPIClient : NSObject


+ (_Nullable instancetype)sharedClient;


- (void)addRequest:(BSRequest * _Nullable)request;

- (void)addDownloadRequest:(BSDownloadRequest * _Nullable)request;


@end
