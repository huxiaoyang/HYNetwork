//
//  BSDownloadRequest.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 2017/3/5.
//  Copyright © 2017年 Xiao Yang. All rights reserved.
//

#import "BSBasicsRequest.h"
@class BSDownloadRequest;


typedef void (^BSDownRequestCompletionBlock) (__kindof BSDownloadRequest * _Nullable request);


@interface BSDownloadRequest : BSBasicsRequest


@property (nonatomic, copy, nullable) BSDownRequestCompletionBlock successCompletionBlock;


@property (nonatomic, copy, nullable) BSDownRequestCompletionBlock failureCompletionBlock;


/**
 *  数据请求
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)startWithCompletionSuccess:(_Nullable BSDownRequestCompletionBlock)success
                           failure:(_Nullable BSDownRequestCompletionBlock)failure;

- (void)start;

/**
 *  下载事件时重写该方法
 *
 *  @return Destination回调事件
 */
- (nullable BSDownloadDestinationBlock)downloadDestinationBlock;


/**
 *  防止循环引用
 */
- (void)clearCompletionBlock;


/**
 *  当前下载任务
 */
@property (atomic, strong, nullable) NSURLSessionDownloadTask *currentURLSessionDownloadTask;


/**
 *  是否开启断点下载 - 默认'NO'不开启
 */
- (BOOL)isOpenResumeDownload;


/**
 *  当前下载任务暂停后的resumeData
 */
@property (nonatomic, strong, nullable) NSData *currentResumeData;


/**
 *  下载完成后保存的文件名
 */
- (nullable NSString *)savedDownloadFileName;


/**
 *  下载完成后保存的路径
 */
- (nullable NSURL *)downloadFilePath;


/**
 *  已下载总数下载
 */
@property (nonatomic, assign) NSUInteger lastTotalWriten;


/**
 *  已下载总数下载
 */
- (void)setDownloadTaskSuspend:(nullable void(^)(NSData * _Nullable resumeData))completed;


/**
 *  是否已经下载完成
 */
- (BOOL)isDownloadTaskCompleted;


/**
 *  获取断点数据
 */
- (nullable NSData *)getDownloadResumeData;


/**
 *  下载完成后，修改文件名称
 */
- (BOOL)modifyContentWithName:(nullable NSString *)name;


@end
