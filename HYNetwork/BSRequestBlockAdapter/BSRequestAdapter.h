//
//  BSRequestAdapter.h
//  void_network
//
//  Created by void on 2018/8/23.
//  Copyright © 2018年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSBlockBasicsRequest.h"

@interface BSRequestAdapter : NSObject

@property (nonatomic, strong, readonly) BSBlockBasicsRequest *request;

#pragma mark - 请求方式
+ (BSRequestAdapter *(^)(NSString *))get;
+ (BSRequestAdapter *(^)(NSString *))post;
+ (BSRequestAdapter *(^)(NSString *))upload;
+ (BSRequestAdapter *(^)(NSString *))download;

#pragma mark - body参数 / head参数
- (BSRequestAdapter *(^)(NSDictionary *))headerField;
- (BSRequestAdapter *(^)(NSDictionary *))params;

#pragma mark -  请求超时时间
- (BSRequestAdapter *(^)(NSTimeInterval))timeoutInterval;

#pragma mark - 上传文件时 Multipart 回调
- (BSRequestAdapter *(^)(BSConstructingBlock))constructingMultipartBlock;

#pragma mark - 请求进度回调
- (BSRequestAdapter *(^)(BSRequestProgress))progressBlock;

#pragma mark - 解析model class
- (BSRequestAdapter *(^)(Class))modelClass;

#pragma mark - 缓存
- (BSRequestAdapter *(^)(BOOL))ignoreCache; //  是否忽略 为true时 即使cacheTimeInSeconds > 0 也不开启缓存
- (BSRequestAdapter *(^)(BOOL))writeCacheAsynchronously; // 是否异步保存
- (BSRequestAdapter *(^)(NSTimeInterval))cacheTimeInSeconds; // 缓存时间 小于0不开启

#pragma mark - 下载
- (BSRequestAdapter *(^)(BOOL))openResumeDownload; // 是否开启断点下载
- (BSRequestAdapter *(^)(BSDownloadDestinationBlock))downloadDestinationBlock; // 下载完成后保存路径


#pragma mark - request / response Serializer
- (BSRequestAdapter *(^)(BSRequestSerializerType))requestSerializerType;
- (BSRequestAdapter *(^)(AFHTTPRequestSerializer *))requestSerializer;
- (BSRequestAdapter *(^)(BSResponseSerializerType))responseSerializerType;
- (BSRequestAdapter *(^)(AFHTTPResponseSerializer *))responseSerializer;

#pragma mark - 无回调请求开始
- (BSRequestAdapter *(^)(void))fetch;

#pragma mark - 有回调请求开始
- (BSRequestAdapter *(^)(BSRequestCompletionBlock))success;
- (BSRequestAdapter *(^)(BSRequestCompletionBlock))failure;
- (BSRequestAdapter *(^)(BSRequestCompletionBlock))always;

#pragma mark - 请求取消
- (void)cancel;

@end
