//
//  ViewController.m
//  HYNetWork
//
//  Created by ucredit-XiaoYang on 16/6/21.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "ViewController.h"
#import "testRequest.h"
#import "testModel.h"
#import "TestDownloadRequest.h"



@interface ViewController ()

@end

@implementation ViewController {
    testRequest *_testRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    TestDownloadRequest *download = [[TestDownloadRequest alloc] init];
//    [download startWithCompletionSuccess:^(__kindof BSDownloadRequest * _Nullable request) {
//        NSLog(@"%@", request);
//    } failure:^(__kindof BSDownloadRequest * _Nullable request) {
//        NSLog(@"%@", request);
//    }];
    
    _testRequest = [[testRequest alloc] init];
    [_testRequest startWithCompletionSuccess:^(__kindof BSRequest * _Nullable request) {
        NSLog(@"---- > %@", request.responseModel);
    } failure:^(__kindof BSRequest * _Nullable request) {
        NSLog(@"---- > %@", request.responseModel);
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_testRequest taskCancel]; // 页面消失时，停止网络请求
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
