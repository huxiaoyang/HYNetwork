//
//  AppDelegate.m
//  HYNetWork
//
//  Created by ucredit-XiaoYang on 16/6/21.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BSNetworkConfig.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)configNetwork {
    BSNetworkConfig *config = [BSNetworkConfig sharedInstance];
    config.baseURL = @"http://bbs.cehome.com";
    
    // 重写responseParams时，如果某个字段不存在，不要为空，随便写一个值
    config.responseParams = @{REQUEST_DATA    : @"items",
                              REQUEST_MESSAGE : @"message",
                              REQUEST_CODE    : @"ret",
                              REQUEST_TIME    : @"time"
                              };
    
    
////     设置缓存时间即开启缓存，默认不开启
//        config.cacheExpirationInterval = 300; // 不为0时开启缓存
////     缓存策略
//        config.customURLCachePolicy = BSRequestUseCacheWhenAnytime;
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configNetwork];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    ViewController *VC = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
