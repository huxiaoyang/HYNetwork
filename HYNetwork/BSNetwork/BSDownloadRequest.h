//
//  BSDownloadRequest.h
//  BSKit
//
//  Created by ucredit-XiaoYang on 2017/3/5.
//  Copyright © 2017年 Xiao Yang. All rights reserved.
//

#import "BSCacheRequest.h"


typedef NSURL * _Nullable (^BSDownloadDestinationBlock)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response);


@interface BSDownloadRequest : BSCacheRequest

/**
 *  下载事件时重写该方法
 *
 *  @return Destination回调事件
 */
- (nullable BSDownloadDestinationBlock)downloadDestinationBlock;

/**
 *  是否开启断点下载 - 默认'NO'不开启
 */
- (BOOL)isOpenResumeDownload;


/**
 *  当前下载任务
 */
@property (atomic, strong, nullable) NSURLSessionDownloadTask *currentURLSessionDownloadTask;


/**
 *  当前下载任务暂停后的resumeData
 */
@property (nonatomic, strong, nullable) NSData *currentResumeData;


/**
 *  下载完成后保存的文件名
 */
@property (nonatomic, copy, readonly) NSString *savedDownloadFileName;


/**
 *  下载完成后保存的路径
 */
@property (nonatomic, strong, readonly) NSURL *downloadFilePath;

/**
 *  是否已经下载完成
 */
@property (nonatomic, assign, readonly) BOOL downloadTaskCompleted;


/**
 *  已下载总数下载
 */
@property (nonatomic, assign) int64_t lastTotalWriten;


/**
 *  已下载总数下载
 */
- (void)setDownloadTaskSuspend:(nullable void(^)(NSData * _Nullable resumeData))completed;


/**
 *  获取断点数据 - 只读
 */
- (nullable NSData *)getDownloadResumeData;


/**
 *  下载完成后，修改文件名称 - 只读
 */
- (BOOL)modifyContentWithName:(nullable NSString *)name;


@end
