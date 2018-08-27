//
//  BSNetworkPrivate.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 16/9/26.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BSBasicsRequest;
@class BSRequest;


@interface BSNetworkPrivate : NSObject

+ (NSString *)buildRequestUrl:(BSBasicsRequest *)request;


+ (NSString *)md5StringFromString:(NSString *)string;


+ (BOOL)extractIdentity:(SecIdentityRef*)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data;


#pragma mark - Throw exceptiont
+ (void)throwExceptiont:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
