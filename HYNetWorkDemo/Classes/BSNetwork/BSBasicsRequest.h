//
//  BSBasicsRequest.h
//  testAFNetWorking
//
//  Created by XiaoYang on 16/1/29.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


typedef NS_ENUM(NSUInteger, BSRequestMethod) {
    BSRequestMethodGet,
    BSRequestMethodPost,
    BSRequestMethodUpload,
    BSRequestMethodDownload,
};


typedef void (^BSConstructingBlock)(id <AFMultipartFormData> _Nonnull formData);

typedef NSURL * _Nullable (^BSDownloadDestinationBlock)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response);

typedef void (^BSRequestProgress)(NSProgress * _Nullable progress);



@interface BSBasicsRequest : NSObject


/**
 *  @return 请求的URL
 *  建议返回API URL
 *  如果以『http』开头的全路径，则忽略baseURL
 */
- (nullable NSString *)requestUrl;


/**
 *  @return 请求的连接超时时间，默认为30秒
 */
- (NSTimeInterval)requestTimeoutInterval;


/**
 *  @return 请求的参数列表
 */
- (nullable id)requestArgument;


/**
 *  @return 公共参数
 */
- (nullable id)globalArgument;


/**
 *  @return HTTP请求header
 */
- (nullable id)requestHTTPHeaderField;


/**
 *  @return Http请求的方法
 */
- (BSRequestMethod)requestMethod;


/**
 *  @return 承载json解析后数据实体
 */
- (nullable Class)modelClass;


/**
 *  上传文件事件时重写该方法
 *
 *  @return Multipart回调事件
 */
- (nullable BSConstructingBlock)constructingMultipartBlock;

/**
 *  下载事件时重写该方法
 *
 *  @return Destination回调事件
 */
- (nullable BSDownloadDestinationBlock)downloadDestinationBlock;

/**
 *  网络请求进度
 *
 *  @return 进度
 */
- (nullable BSRequestProgress)progressBlock;

/**
 *  当前请求任务
 */
@property (nonatomic, strong, nullable) NSURLSessionDataTask *currentURLSessionDataTask;


/**
 *  当前下载任务
 */
@property (nonatomic, strong, nullable) NSURLSessionDownloadTask *currentURLSessionDownloadTask;


@property (nonatomic, assign) NSURLSessionTaskState taskState;

/**
 *  网络请求当前task状态 - 是否正在执行中
 */
@property (nonatomic, assign, getter=isTaskRunning) BOOL taskRunning;

/**
 *  取消当前网络请求
 */
- (void)taskCancel;


@end
