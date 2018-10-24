//
//  BSBasicsRequest.h
//  testAFNetWorking
//
//  Created by XiaoYang on 16/1/29.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AFMultipartFormData;
@class AFHTTPRequestSerializer;
@class AFHTTPResponseSerializer;
@class ResponseModel;


FOUNDATION_EXPORT NSString *const _Nonnull BSRequestErrorDomain;

typedef NS_ENUM(NSUInteger, BSRequestMethod) {
    BSRequestMethodGet,
    BSRequestMethodPost,
    BSRequestMethodUpload,
    BSRequestMethodDownload,
};

typedef NS_ENUM(NSUInteger, BSRequestSerializerType) {
    // NSData type
    BSRequestSerializerTypeHTTP,
    // JSON object type
    BSRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, BSResponseSerializerType) {
    // JSON object type
    BSResponseSerializerTypeJSON,
    // NSData type
    BSResponseSerializerTypeHTTP,
};


typedef void (^BSConstructingBlock)(id <AFMultipartFormData> _Nonnull formData);

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
@property (nonatomic, strong, readonly) id parameters;


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
 *  @return 请求类型
 */
- (BSRequestSerializerType)requestSerializerType;
- (AFHTTPRequestSerializer *)requestSerializer;


/**
 *  @return 返回类型
 */
- (BSResponseSerializerType)responseSerializerType;
- (AFHTTPResponseSerializer *)responseSerializer;


/**
 *  上传文件事件时重写该方法
 *
 *  @return Multipart回调事件
 */
- (nullable BSConstructingBlock)constructingMultipartBlock;


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
 *  当前任务状态
 */
@property (nonatomic, assign) NSURLSessionTaskState taskState;

/**
 *  网络请求当前task状态 - 是否正在执行中
 */
@property (nonatomic, assign, getter=isTaskRunning) BOOL taskRunning;

/**
 *  取消当前网络请求
 */
- (void)taskCancel;


/**
 *  获取当前网络请求完整URL
 */
- (nullable NSURL *)currentCompleteURL;


#pragma mark - 请求返回数据
/**
 *  请求返回对象
 */
@property (nonatomic, strong, nullable) id responseObject;

/**
 *  返回NSData对象
 */
@property (nonatomic, strong, nullable) NSData *responseData;

/**
 *  返回json对象
 */
@property (nonatomic, strong, nullable) id responseJOSNObject;

/**
 *  json解析后的Model
 *  返回success时，jsonObject是NSDictionary类型
 *  返回error时，ResponseModel是错误model，messge是错误信息
 */
@property (nonatomic, strong, nullable) ResponseModel *responseModel;

/**
 *  错误信息
 */
@property (nonatomic, strong, nullable) NSError *error;


@end
