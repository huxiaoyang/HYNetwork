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

- (BSRequestMethod)requestMethod {
    return BSRequestMethodDownload;
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

- (BSDownloadDestinationBlock)downloadDestinationBlock {
    return ^(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:@"test.jpeg"];
    };
}

- (nullable BSRequestProgress)progressBlock {
    return ^(NSProgress * _Nullable progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"下载进度 --- > %lld", progress.completedUnitCount);
        });
    };
}

@end
