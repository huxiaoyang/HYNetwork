//
//  ResponseModel.h
//  BSKit
//
//  Created by XiaoYang on 16/1/24.
//  Copyright © 2016年 Xiao Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseModel : NSObject

@property (nonatomic, strong, nullable) NSNumber *code;

@property (nonatomic, copy, nullable) NSString *message;

// 请求返回的model
// 下载时是文件filePath
@property (nonatomic, strong, nullable) id data;

@property (nonatomic, strong, nullable) NSNumber *timestamp;

@end
