//
//  GHttpSessionTask.h
//  NSURLSessionTest
//
//  Created by apple on 15/11/24.
//  Copyright © 2015年 apple. All rights reserved.
//

/*
 需求：
 1、配置http头
    setHttpHeader
 2、
 */

#import <Foundation/Foundation.h>
#import "CC_HttpResponseModel.h"

@interface CC_HttpTask : NSObject<NSURLSessionDelegate>{
    void (^finishCallbackBlock)(NSString *errorStr, ResModel *model); // 执行完成后回调的block
}

+ (instancetype)getInstance;

@property(nonatomic,assign) BOOL needResponseDate;
@property(nonatomic,retain) NSDictionary *requestHTTPHeaderFieldDic;
@property(nonatomic,retain) NSString *signKeyStr;
@property(nonatomic,retain) NSDictionary *extreDic;

@property(strong) void (^finishCallbackBlock)(NSString *error,ResModel *result);

/**
 * paramsDic的关键字
 * getDate 可以获取时间
 */
- (void)post:(NSURL *)url params:(id)paramsDic model:(ResModel *)model finishCallbackBlock:(void (^)(NSString *, ResModel *))block;
- (void)get:(NSURL *)url params:(id)paramsDic model:(ResModel *)model finishCallbackBlock:(void (^)(NSString *, ResModel *))block;

@end
