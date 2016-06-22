//
//  BSAPIClient.h
//  testAFNetWorking
//
//  Created by XiaoYang on 16/1/29.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "AFNetworking.h"
#import "BSRequest.h"
#import "ResponseModel.h"


extern NSString *const _Nonnull BSAPIClientRequestFailureNotification;


@interface BSAPIClient : AFHTTPSessionManager


+ (_Nullable instancetype)sharedClient;


- (void)addRequest:(BSRequest * _Nullable)request;

@end
