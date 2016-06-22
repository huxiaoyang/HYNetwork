//
//  BSReuqest.m
//  testAFNetWorking
//
//  Created by ucredit-XiaoYang on 16/4/5.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

#import "BSRequest.h"
#import "BSAPIClient.h"


@implementation BSRequest


#pragma mark - AFSession Rquest

- (void)start {
    
    [[BSAPIClient sharedClient] addRequest:self];
}

- (void)setCompletionBlockWithSuccess:(BSRequestCompletionBlock)success
                              failure:(BSRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}


- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}


- (void)startWithCompletionSuccess:(BSRequestCompletionBlock)success
                           failure:(BSRequestCompletionBlock)failure {
    
    [self setCompletionBlockWithSuccess:success
                                failure:failure];
    [self start];
    
}



@end
