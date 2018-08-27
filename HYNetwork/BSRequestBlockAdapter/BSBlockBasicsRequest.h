//
//  BSBlockBasicsRequest.h
//  void_network
//
//  Created by void on 2018/8/23.
//  Copyright © 2018年 XiaoYang. All rights reserved.
//

#import "BSRequest.h"
#import "BSRequestAdapterProtocol.h"
#import "BSCacheRequestAdapterProtocol.h"
#import "BSDownloadAdapterProtocol.h"

@interface BSBlockBasicsRequest : BSRequest <BSRequestAdapterProtocol, BSCacheRequestAdapterProtocol, BSDownloadAdapterProtocol>



@end
