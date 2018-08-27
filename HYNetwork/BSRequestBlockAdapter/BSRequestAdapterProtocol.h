//
//  BSRequestAdapterProtocol.h
//  void_network
//
//  Created by void on 2018/8/23.
//  Copyright © 2018年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BSRequestAdapterProtocol <NSObject>

/// API
@property (nonatomic, copy) NSString *api;

/// 请求参数
@property (nonatomic, strong) NSDictionary *params;

/// http 头参数
@property (nonatomic, strong) NSDictionary *headerField;

/// 超时时间
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// 请求方式
@property (nonatomic, assign) BSRequestMethod method;

/// 上传操作时 multipart 回调
@property (nonatomic, copy) BSConstructingBlock constructingMultipartBlock;

/// 请求进度
@property (nonatomic, copy) BSRequestProgress progressBlock;

/// 解析对象
@property (nonatomic, strong) Class modelClass;

/// serializer
@property (nonatomic, assign) BSRequestSerializerType requestSerializerType;
@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic, assign) BSResponseSerializerType responseSerializerType;
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;


@end
