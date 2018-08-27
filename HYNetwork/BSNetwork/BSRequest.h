//
//  BSReuqest.h
//  testAFNetWorking
//
//  Created by ucredit-XiaoYang on 16/4/5.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "BSDownloadRequest.h"
@class BSRequest;


typedef void (^BSRequestCompletionBlock) (__kindof BSRequest * _Nullable request);



@interface BSRequest : BSDownloadRequest



@property (nonatomic, copy, nullable) BSRequestCompletionBlock successCompletionBlock;


@property (nonatomic, copy, nullable) BSRequestCompletionBlock failureCompletionBlock;


/**
 *  数据请求
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)startWithCompletionSuccess:(_Nullable BSRequestCompletionBlock)success
                           failure:(_Nullable BSRequestCompletionBlock)failure;


/**
 *  数据请求 - 只请求
 */
- (void)addRequest;


/**
 *  防止循环引用
 */
- (void)clearCompletionBlock;


/**
 *  缓存数据
 */
- (void)requestCompletePreprocessor;


/**
 *  请求返回值过滤
 @return YES-继续执行 NO-阻塞，不会执行成功回调
 */
- (BOOL)filterSuccessRequestCompletion:(__kindof BSRequest * _Nullable )request;

- (BOOL)filterFailureRequestCompletion:(__kindof BSRequest * _Nullable )request;


@end
