//
//  testRequest.m
//  HYNetWork
//
//  Created by ucredit-XiaoYang on 16/6/22.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "testRequest.h"
#import "testModel.h"


@implementation testRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/api.php";
}


- (id)requestArgument {
    return @{@"mod"     : @"getAppIndexThreadList",
             @"page"    : @1
             };
}


- (BSRequestMethod)requestMethod {
    return BSRequestMethodGet;
}


- (Class)modelClass {
    return [testModel class];
}


/**
 *  设置http header
 */
//- (id)requestHTTPHeaderField {
//    return @{@"User-Agent" : @""
//             };
//}



/**
 *  上传文件
 *  试例 - 当requestMethod == BSRequestMrthodUpload 时重写
 */
//- (BSConstructingBlock)constructingMultipartBlock {
//    return ^(id <AFMultipartFormData> _Nonnull formData) {
//        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
//        NSString *name = @"image.jpg";
//        NSString *formKey = @"file";
//        NSString *type = @"image/jpeg";
//        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
//    };
//}


/**
 *  下载文件
 *  试例 - 当requestMethod == BSRequestMethodDownload 时重写
 */
//- (BSDownloadDestinationBlock)downloadDestinationBlock {
//    return ^(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//    };
//}


// 试例 - 进度
//- (BSRequestProgress)progressBlock {
//    return ^(NSProgress * _Nullable progress) {
//
//    };
//}





@end
