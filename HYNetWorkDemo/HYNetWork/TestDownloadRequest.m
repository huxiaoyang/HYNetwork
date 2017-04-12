//
//  BSTestDownloadRequest.m
//  BSKit
//
//  Created by ucredit-XiaoYang on 2017/3/5.
//  Copyright © 2017年 Xiao Yang. All rights reserved.
//

#import "TestDownloadRequest.h"

@implementation TestDownloadRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)requestUrl {
    return @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=644889234,2435501325&fm=23&gp=0.jpg";
}

- (BOOL)isOpenResumeDownload {
    return YES;
}

- (id)requestArgument {
    return @{};
}

- (nullable BSRequestProgress)progressBlock {
    return ^(NSProgress * _Nullable progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"下载进度 --- > %zd", progress.completedUnitCount);
        });
    };
}

@end
