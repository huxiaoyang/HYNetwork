//
//  BSNetworkPrivate.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/9/26.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BSRequest;

@interface BSNetworkPrivate : NSObject

+ (NSString *)buildRequestUrl:(BSRequest *)request;


+ (id)currentArgument:(BSRequest *)request;


+ (NSString *)md5StringFromString:(NSString *)string;


#pragma mark JSON TO Model
+ (id)responseModel:(id)responseObject request:(BSRequest *)request;

+ (id)responseModel:(NSError *)error;

#pragma mark - Throw exceptiont
+ (void)throwExceptiont:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
