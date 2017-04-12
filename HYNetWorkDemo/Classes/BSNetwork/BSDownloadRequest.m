//
//  BSDownloadRequest.m
//  BSKit
//
//  Created by ucredit-XiaoYang on 2017/3/5.
//  Copyright © 2017年 Xiao Yang. All rights reserved.
//

#import "BSDownloadRequest.h"
#import "BSAPIClient.h"
#import "BSNetworkPrivate.h"


@implementation BSDownloadRequest

- (void)start {
    [[BSAPIClient sharedClient] addDownloadRequest:self];
}

- (void)setCompletionBlockWithSuccess:(BSDownRequestCompletionBlock)success
                              failure:(BSDownRequestCompletionBlock)failure {
        self.successCompletionBlock = success;
        self.failureCompletionBlock = failure;
}


- (void)startWithCompletionSuccess:(BSDownRequestCompletionBlock)success
                           failure:(BSDownRequestCompletionBlock)failure {
    
    [self setCompletionBlockWithSuccess:success
                                failure:failure];
    [self start];
    
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}



#pragma mark - getter

- (NSURLSessionTaskState)taskState {
    return self.currentURLSessionDownloadTask.state;
}

- (BOOL)isOpenResumeDownload {
    return NO;
}

- (BOOL)isTaskRunning {
    return self.currentURLSessionDownloadTask ? self.currentURLSessionDownloadTask.state == NSURLSessionTaskStateRunning : NO;
}

- (void)taskCancel {
    if ([self isTaskRunning]) {
        [self.currentURLSessionDownloadTask cancel];
        return;
    }
}

- (BSRequestMethod)requestMethod {
    return BSRequestMethodDownload;
}


- (BSDownloadDestinationBlock)downloadDestinationBlock {
    if ([self requestMethod] == BSRequestMethodDownload) {
        return ^(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:@"test.jpeg"];
        };
    }
    return nil;
}


#pragma mark -  断点下载 -- 服务器必须支持【Range】
- (void)setDownloadTaskSuspend:(void(^)(NSData * _Nullable resumeData))completed {
    if (!self.currentURLSessionDownloadTask) return;
    [self.currentURLSessionDownloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (![self saveDownloadResumeData:resumeData]) {
            NSLog(@"临时下载数据保存失败");
        }
        if (completed) completed(resumeData);
    }];
}

- (NSString *)savedDownloadFileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSURL *resumePlistUrl = [NSURL fileURLWithPath:paths.firstObject];
    resumePlistUrl = [resumePlistUrl URLByAppendingPathComponent:self.resumeConfigPlistName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:resumePlistUrl.path]) {
        return nil;
    }
    //获取需要重新下载的文件名
    NSDictionary *listDic = [NSDictionary dictionaryWithContentsOfURL:resumePlistUrl];
    __block NSString *savedName = nil;
    [listDic enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:self.savedName]) {
            savedName = obj;
            *stop = YES;
        }
    }];
    
    return savedName;
}

- (BOOL)isDownloadTaskCompleted {
    return self.savedDownloadFileName;
}

- (NSURL *)downloadFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:paths.firstObject];
    return [documentsDirectoryURL URLByAppendingPathComponent:self.savedDownloadFileName];
}


- (NSData *)getDownloadResumeData {
    @synchronized (self) {
        //读取缓存目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSURL *resumePlistUrl = [NSURL fileURLWithPath:paths.firstObject];
        resumePlistUrl = [resumePlistUrl URLByAppendingPathComponent:self.resumeConfigPlistName];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:resumePlistUrl.path]) {
            return nil;
        }
        //获取需要重新下载的文件名
        NSDictionary *listDic = [NSDictionary dictionaryWithContentsOfURL:resumePlistUrl];
        __block NSString *cacheName = nil;
        [listDic enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isEqualToString:self.cacheName]) {
                cacheName = obj;
                *stop = YES;
            }
        }];
        
        //返回需要下载的数据
        NSData *data = nil;
        if (cacheName) {
            //caches文件下目录
            NSURL *cacheTmpUrl = [NSURL fileURLWithPath:paths.firstObject];
            cacheTmpUrl = [cacheTmpUrl URLByAppendingPathComponent:cacheName];
            
            //tmp文件目录
            NSString *tmpContent = NSTemporaryDirectory();
            NSString *tmpStr = [NSString stringWithFormat:@"%@%@",tmpContent,cacheName];
            NSURL *tmpSaveUrl = [NSURL fileURLWithPath:tmpStr];
            
            //将缓存文件拷贝至tmp目录下
            NSFileManager *manager = [NSFileManager defaultManager];
            NSError *error;
            if ([manager fileExistsAtPath:tmpSaveUrl.path]) {
                [manager removeItemAtURL:tmpSaveUrl error:nil];
            }
            
            if([manager copyItemAtURL:cacheTmpUrl toURL:tmpSaveUrl error:&error]) {
                //获取resumeData文件
                NSURL *resumeDatUrl = [NSURL fileURLWithPath:paths.firstObject];
                resumeDatUrl = [resumeDatUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"Resume_%@",cacheName]];
                data = [NSData dataWithContentsOfURL:resumeDatUrl];
            }
            else {
                NSLog(@"拷贝文件失败  %s error = %@",__FUNCTION__,error);
            }
        }
        
        return data;
    }
}

- (BOOL)saveDownloadResumeData:(NSData *)resumeData {
    @synchronized (self) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *name = [self getNameFromResumeData:resumeData];
        
        //获取临时文件的路径
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *tmpStr = [NSString stringWithFormat:@"%@%@",tmpPath,name];
        NSURL *tmpUrl = [NSURL fileURLWithPath:tmpStr];
        
        //获取存储临时文件的路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSURL *saveTmpUrl = [NSURL fileURLWithPath:paths.firstObject];
        saveTmpUrl = [saveTmpUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",name]];
        
        //获取存放resumeData的路径
        NSURL *saveResumeDatUrl = [NSURL fileURLWithPath:paths.firstObject];
        saveResumeDatUrl = [saveResumeDatUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"Resume_%@",name]];
        
        //获取管理缓存的plist字典  不存在的话 就创建一个
        NSURL *resumePlistUrl = [NSURL fileURLWithPath:paths.firstObject];
        resumePlistUrl = [resumePlistUrl URLByAppendingPathComponent:self.resumeConfigPlistName];
        NSMutableDictionary *dicOfMovie;
        if([manager fileExistsAtPath:resumePlistUrl.path]) {
            dicOfMovie = [NSMutableDictionary dictionaryWithContentsOfURL:resumePlistUrl];
        }
        else {
            dicOfMovie = [NSMutableDictionary dictionary];
            [dicOfMovie writeToFile:resumePlistUrl.path atomically:YES];
        }
        
        NSError *error = nil;
        //拷贝tmp文件至Caches文件夹
        if ([manager fileExistsAtPath:saveTmpUrl.path]) {
            [manager removeItemAtURL:saveTmpUrl error:nil];
        }
        if(![manager copyItemAtURL:tmpUrl toURL:saveTmpUrl error:&error]) {
            NSLog(@"拷贝临时文件失败  %@",error);
            return NO;
        }
        
        //将resumeData写入到Document文件夹下
        if ([manager fileExistsAtPath:saveResumeDatUrl.path]) {
            [manager removeItemAtURL:saveResumeDatUrl error:nil];
        }
        if(![resumeData writeToURL:saveResumeDatUrl atomically:YES]){
            NSLog(@"写入resumeData失败");
            return NO;
        }
        
        //修改缓存目录
        if (dicOfMovie) {
            [dicOfMovie setValue:name forKey:self.cacheName];
            [manager removeItemAtPath:resumePlistUrl.path error:nil];
            [dicOfMovie writeToFile:resumePlistUrl.path atomically:YES];
        }
        
        return YES;
    }
}

- (BOOL)modifyContentWithName:(NSString*)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSURL *resumePlistUrl = [NSURL fileURLWithPath:paths.firstObject];
    resumePlistUrl = [resumePlistUrl URLByAppendingPathComponent:self.resumeConfigPlistName];
    NSMutableDictionary *dicOfMovie;
    if([manager fileExistsAtPath:resumePlistUrl.path]) {
        dicOfMovie = [NSMutableDictionary dictionaryWithContentsOfURL:resumePlistUrl];
        [dicOfMovie setValue:name forKey:self.savedName];
    }
    
    if (dicOfMovie) {
        [manager removeItemAtURL:resumePlistUrl error:nil];
        [dicOfMovie writeToFile:resumePlistUrl.path atomically:YES];
        return YES;
    }
    
    return NO;
}

- (NSString *)getNameFromResumeData:(NSData *)resumeData {
    NSString *resumeDataStr =[[NSString alloc]initWithData:resumeData encoding:NSUTF8StringEncoding];
    NSString *fileName =[resumeDataStr componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"].lastObject;
    fileName = [fileName componentsSeparatedByString:@"</string>"].firstObject;
    return fileName;
}

- (NSString *)getSizeFormResumeData:(NSData *)resumeData {
    NSString *resumeDataStr =[[NSString alloc]initWithData:resumeData encoding:NSUTF8StringEncoding];
    NSString *fileSize =   [[resumeDataStr componentsSeparatedByString:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>"]lastObject];
    
    fileSize = [fileSize componentsSeparatedByString:@"</integer>"].firstObject;
    return fileSize;
}

- (NSString *)cacheName {
    NSString *key = [BSNetworkPrivate buildRequestUrl:self];
    NSString *cacheName = [NSString stringWithFormat:@"%@+%@", key, @"NO"];
    return [BSNetworkPrivate md5StringFromString:cacheName];
}

- (NSString *)savedName {
    NSString *key = [BSNetworkPrivate buildRequestUrl:self];
    NSString *savedName = [NSString stringWithFormat:@"%@+%@", key, @"YES"];
    return [BSNetworkPrivate md5StringFromString:savedName];
}

- (NSString *)resumeConfigPlistName {
    return @"resumeConfig.plist";
}

@end
