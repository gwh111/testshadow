//
//  AppShare.m
//  testshadow
//
//  Created by gwh on 2018/6/14.
//  Copyright © 2018年 gwh. All rights reserved.
//

#import "AppShare.h"

@implementation AppShare

static AppShare *instance = nil;
static dispatch_once_t onceToken;

+ (instancetype)getInstance
{
    dispatch_once(&onceToken, ^{
        instance = [[AppShare alloc] init];
    });
    return instance;
}

@end
