//
//  GHttpSessionTask.m
//  NSURLSessionTest
//
//  Created by apple on 15/11/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "CC_GHttpSessionTask.h"
#import "CC_FormatDic.h"
#import "CC_Share.h"
#import "CC_RequestRecordTool.h"

@implementation CC_HttpTask
@synthesize finishCallbackBlock;

static CC_HttpTask *instance = nil;
static dispatch_once_t onceToken;

+ (instancetype)getInstance
{
    dispatch_once(&onceToken, ^{
        instance = [[CC_HttpTask alloc] init];
    });
    return instance;
}

- (void)post:(NSURL *)url params:(id)paramsDic model:(ResModel *)model finishCallbackBlock:(void (^)(NSString *, ResModel *))block{
    [self request:url Params:paramsDic model:model FinishCallbackBlock:^(NSString *error, ResModel *result) {
        block(error,result);
    } type:0];
}

- (void)get:(NSURL *)url params:(id)paramsDic model:(ResModel *)model finishCallbackBlock:(void (^)(NSString *, ResModel *))block{
    [self request:url Params:paramsDic model:model FinishCallbackBlock:^(NSString *error, ResModel *result) {
        block(error,result);
    } type:1];
}

- (void)request:(NSURL *)url Params:(id)paramsDic model:(ResModel *)model FinishCallbackBlock:(void (^)(NSString *, ResModel *))block type:(int)type{
    
    model.serviceStr=paramsDic[@"service"];
    
    CC_HttpTask *executorDelegate = [[CC_HttpTask alloc] init];
    executorDelegate.finishCallbackBlock = block; // 绑定执行完成时的block
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession  *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:executorDelegate delegateQueue:nil];
    
    if ([paramsDic isKindOfClass:[NSDictionary class]]) {
        paramsDic=[[NSMutableDictionary alloc]initWithDictionary:paramsDic];
    }
    if (!paramsDic[@"timestamp"]) {
        NSDate *datenow = [NSDate date];
        NSString *timeSp = [NSString stringWithFormat:@"%.0f", [datenow timeIntervalSince1970]*1000];
        [paramsDic setObject:timeSp forKey:@"timestamp"];
    }
    if (_extreDic) {
        NSArray *keys=[_extreDic allKeys];
        for (int i=0; i<keys.count; i++) {
            [paramsDic setObject:_extreDic[keys[i]] forKey:keys[i]];
        }
    }
    
    if (!_signKeyStr) {
        if (model.debug) {
            CCLOG(@"_signKeyStr为空");
        }
    }
    NSString *paraString=[CC_FormatDic getSignFormatStringWithDic:paramsDic andMD5Key:_signKeyStr];
    
    NSURLRequest *urlReq;
    if (type==0) {
        urlReq=[self postRequestWithUrl:url andParamters:paraString];
    }else{
        urlReq=[self getRequestWithUrl:url andParamters:paraString];
    }
   
    model.requestUrlStr=urlReq.URL.absoluteString; model.requestStr=ccstr(@"%@%@",urlReq.URL.absoluteString,paraString);
    NSURLSessionDownloadTask *mytask=[session downloadTaskWithRequest:urlReq completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [session finishTasksAndInvalidate];
        
        if (paramsDic[@"getDate"]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            [self loadResponseDate:model response:httpResponse];
        }
        
        if (error) {
            [model parsingError:error];
        }else{
            NSString *resultStr= [NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:&error];
            if (!resultStr) {
                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                resultStr= [NSString stringWithContentsOfURL:location encoding:enc error:&error];
                if (model.debug&&resultStr) {
                    CCLOG(@"返回头是GBK编码");
                }
            }
            [model parsingResult:resultStr];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (model.debug) {
                [[CCReqRecord getInstance]insertRequestDataWithHHSService:paramsDic[@"service"] requestUrl:url.absoluteString parameters:paraString];
            }
            executorDelegate.finishCallbackBlock(model.errorStr, model);
        });
        
    }];
    
    [mytask resume];
}

- (void)setHttpHeader:(NSDictionary *)dic{
    _requestHTTPHeaderFieldDic=dic;
}

- (void)setSignKey:(NSString *)str{
    _signKeyStr=str;
}

- (void)setExtreDic:(NSDictionary *)dic{
    _extreDic=dic;
}

- (NSURLRequest *)postRequestWithUrl:(NSURL *)url andParamters:(NSString *)paramsString{
    return [self requestWithUrl:url andParamters:paramsString andType:0];
}

- (NSURLRequest *)getRequestWithUrl:(NSURL *)url andParamters:(NSString *)paramsString{
    return [self requestWithUrl:url andParamters:paramsString andType:1];
}

//创建request
- (NSURLRequest *)requestWithUrl:(NSURL *)url andParamters:(NSString *)paramsString andType:(int)type{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    request.URL=url;
    request.HTTPBody = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *types=@[@"POST",@"GET"];
    [request setHTTPMethod:types[type]];
    [request setTimeoutInterval:10];
    
    if (!_requestHTTPHeaderFieldDic) {
        CCLOG(@"没有设置_requestHTTPHeaderFieldDic");
        return request;
    }
    [request setValue:@"cc-iphone" forHTTPHeaderField:@"appName"];
    [request setValue:[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] forHTTPHeaderField:@"appVersion"];
//    CCLOG(@"%@",request.allHTTPHeaderFields);
    NSArray *keys=[_requestHTTPHeaderFieldDic allKeys];
    for (int i=0; i<keys.count; i++) {
        [request setValue:_requestHTTPHeaderFieldDic[keys[i]] forHTTPHeaderField:keys[i]];
    }
    
    return request;
}

- (void)loadResponseDate:(ResModel *)model response:(NSHTTPURLResponse *)httpResponse{
    //转换时间
    NSString *date = [[httpResponse allHeaderFields] objectForKey:@"Date"];
    date = [date substringFromIndex:5];
    date = [date substringToIndex:[date length]-4];
    NSDateFormatter *dMatter = [[NSDateFormatter alloc] init]; dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dMatter setDateFormat:model.responseDateFormatStr];
    NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: netDate];
    NSDate *localeDate = [netDate dateByAddingTimeInterval: interval];
    model.responseDate=localeDate;
}

@end


