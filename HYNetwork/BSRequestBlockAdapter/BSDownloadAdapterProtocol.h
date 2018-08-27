//
//  BSDownloadAdapterProtocol.h
//  void_network
//
//  Created by void on 2018/8/27.
//  Copyright © 2018年 XiaoYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BSDownloadAdapterProtocol <NSObject>

/// 是否开启断点下载
@property (nonatomic, assign) BOOL openResumeDownload;

/// 下载完成后保存路径
@property (nonatomic, copy) BSDownloadDestinationBlock downloadDestinationBlock;

@end
