//
//  ViewController.m
//  testshadow
//
//  Created by gwh on 2018/6/11.
//  Copyright © 2018年 gwh. All rights reserved.
//

#import "ViewController.h"
#import "CC_Share.h"
#import "AppShare.h"

@interface ViewController (){
    CC_TextField *user_nameT;
    CC_TextField *user_psdT;
    
    
    CC_TextView *displayT;
    
    UIScrollView *sview;
    
    CC_Button *allBt;
    
    NSString *userId;
    NSString *loginKey;
    
    NSMutableDictionary *requetsDic;
}

@end

@implementation ViewController

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEdit];
}

- (void)endEdit{
    [displayT resignFirstResponder];
    [user_nameT resignFirstResponder];
    [user_psdT resignFirstResponder];
    
    NSArray *sv=sview.subviews;
    for (int i=0; i<sv.count; i++) {
        if ([sv[i] isKindOfClass:[CC_TextView class]]) {
            CC_TextField *t=sv[i];
            CCLOG(@"%@",t.placeholder);
            [requetsDic setObject:t.text forKey:t.placeholder];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor blackColor];
    [[CC_UIHelper getInstance]initUIDemoWidth:375 andHeight:782];
    
    {
        user_nameT=[CC_TextField ccr:self.view l:[ccui getRH:10] t:[ccui getRH:50] w:[ccui getRH:100] h:[ccui getRH:40] tc:[UIColor blackColor] bgc:[UIColor whiteColor] f:[UIFont systemFontOfSize:14] ta:0 ph:@"用户名" uie:YES];
    }
    {
        user_psdT=[CC_TextField ccr:self.view l:[ccui getRH:120] t:[ccui getRH:50] w:[ccui getRH:100] h:[ccui getRH:40] tc:[UIColor blackColor] bgc:[UIColor whiteColor] f:[UIFont systemFontOfSize:14] ta:0 ph:@"密码" uie:YES];
    }
    
    {
        CC_Button *leftBt=[CC_Button ccr:self.view l:[ccui getRH:230] t:[ccui getRH:50] w:[ccui getRH:80] h:[ccui getRH:50] ts:@"粘贴" ats:nil tc:[UIColor whiteColor] bgc:nil img:nil bgimg:nil f:[ccui getRFS:14] ta:0 uie:YES];
        [leftBt addTappedOnceDelay:1 withBlock:^(UIButton *button) {
            UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
            [AppShare getInstance].cpStr=pasteboard.string;
        }];
    }
//    {
//        UIView *view=[[UIView alloc]initWithFrame:CGRectMake([ccui getRH:10], [ccui getRH:100], [ccui getW]-[ccui getRH:20], [ccui getRH:40])];
//        view.backgroundColor=[UIColor blackColor];
//        [self.view addSubview:view];
//        view.layer.cornerRadius = 8;
//        view.layer.shadowColor = [UIColor whiteColor].CGColor;
//        view.layer.shadowOffset = CGSizeMake(0, 0);
//        view.layer.shadowOpacity = 1;
//        view.layer.shadowRadius = 4;
//        nameT=[CC_TextView ccr:view l:0 t:0 w:[ccui getW]-[ccui getRH:20] h:[ccui getRH:40] ts:nil ats:nil tc:[UIColor whiteColor] bgc:[UIColor clearColor] f:[UIFont systemFontOfSize:14] ta:0 sb:1 eb:1 uie:1];
//    }
    
    {
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake([ccui getRH:10], [ccui getRH:100], [ccui getW]-[ccui getRH:20], [ccui getRH:100])];
        view.backgroundColor=[UIColor blackColor];
        [self.view addSubview:view];
        view.layer.cornerRadius = 8;
        view.layer.shadowColor = [UIColor whiteColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 0);
        view.layer.shadowOpacity = 1;
        view.layer.shadowRadius = 4;
        
        sview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [ccui getW]-[ccui getRH:20], [ccui getRH:100])];
        sview.backgroundColor=[UIColor clearColor];
        [view addSubview:sview];
    }
    
    {
        displayT=[CC_TextView ccr:self.view l:0 t:[ccui getRH:210] w:[ccui getW] h:[ccui getH]-[ccui getRH:260] ts:nil ats:nil tc:[UIColor greenColor] bgc:[UIColor clearColor] f:[UIFont systemFontOfSize:14] ta:0 sb:1 eb:0 uie:1];
        [CC_CodeClass setLineColorR:1 andG:1 andB:1 andA:1 width:1 view:displayT];
    }
    NSString* str1= [@"我12h22😆" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* str= [@"%E6%88%9112h22%F0%9F%98%86" stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"\\ s=  %@ %@",str1,str);
    
    {
        CC_Button *leftBt=[CC_Button ccr:self.view l:[ccui getRH:10] t:displayT.bottom w:[ccui getRH:80] h:[ccui getRH:50] ts:@"解析" ats:nil tc:[UIColor whiteColor] bgc:nil img:nil bgimg:nil f:[ccui getRFS:14] ta:0 uie:YES];
        [leftBt addTappedOnceDelay:1 withBlock:^(UIButton *button) {
            [self parse];
        }];
        [CC_Animation buttonClick:leftBt];
    }
    
    {
        CC_Button *leftBt=[CC_Button ccr:self.view l:[ccui getRH:90] t:displayT.bottom w:[ccui getRH:80] h:[ccui getRH:50] ts:@"请求" ats:nil tc:[UIColor whiteColor] bgc:nil img:nil bgimg:nil f:[ccui getRFS:14] ta:0 uie:YES];
        [leftBt addTappedOnceDelay:1 withBlock:^(UIButton *button) {
            [self requestAll:0];
        }];
        [leftBt.layer addAnimation:[CC_Animation opacityForever_Animation:1] forKey:@""];
        [CC_Animation buttonClick:leftBt];
    }
    
    {
        allBt=[CC_Button ccr:self.view l:[ccui getRH:180] t:displayT.bottom w:[ccui getRH:80] h:[ccui getRH:50] ts:@"显示部分" ats:nil tc:[UIColor whiteColor] bgc:nil img:nil bgimg:nil f:[ccui getRFS:14] ta:0 uie:YES];
        allBt.selected=YES;
        [allBt addTappedOnceDelay:1 withBlock:^(UIButton *button) {
            button.selected=!button.selected;
            if (button.selected) {
                [button setTitle:@"显示部分" forState:UIControlStateNormal];
            }else{
                [button setTitle:@"显示全" forState:UIControlStateNormal];
            }
        }];
    }
    
    {
        __block ViewController *blockSelf=self;
        CC_Button *leftBt=[CC_Button ccr:self.view l:[ccui getRH:270] t:displayT.bottom w:[ccui getRH:50] h:[ccui getRH:50] ts:@"清空" ats:nil tc:[UIColor whiteColor] bgc:nil img:nil bgimg:nil f:[ccui getRFS:14] ta:0 uie:YES];
        [leftBt addTappedOnceDelay:1 withBlock:^(UIButton *button) {
            [blockSelf clear];
        }];
    }
    
    NSDictionary *record=[ccs getPlistDic:@"record"];
    NSString *total=[[NSString alloc]init];
    NSArray *keys=[record allKeys];
    for (int i=0; i<keys.count; i++) {
        NSString *s=record[keys[i]][@"requestUrl"];
        if (s.length<=1) {
            continue;
        }
        total=[total stringByAppendingString:s];
        total=[total stringByAppendingString:@"?"];
        total=[total stringByAppendingString:record[keys[i]][@"parameters"]];
        total=[total stringByAppendingString:@";"];
    }
    
//    nameT.text=@"http://mapi.xjq.net/client/service.json?";
    
    [AppShare getInstance].cpStr=total;
//    nameT.text=@"http://mapi1.93leju.net/service.json?";
//    contentT.text=@"sign=32b68e1b8e7a2e847abdcd8738d6c2bf&signKey=USS93efafc1d15f4bd084edb3a8f13319ca&timestamp=1527041308726&boardId=4001284152018506210970012948&loginKey=USL7ea222dac482449da0f381403d948d03&service=BOARD_SETTLE_QUERY_BY_ID&authedUserId=8201710118505806;timestamp=1527041308726&roomId=4001414505686106010970019985&loginKey=USL7ea222dac482449da0f381403d948d03&service=ROOM_USER_SETTLE_QUERY_BY_ROOM&authedUserId=8201710118505806";
    
    
}

- (void)parse{
    CCLOG(@"size=%lu",(unsigned long)[AppShare getInstance].cpStr.length);
    
    requetsDic=[[NSMutableDictionary alloc]init];
    NSArray *arr=[[AppShare getInstance].cpStr componentsSeparatedByString:@";"];
    for (int i=0; i<arr.count; i++) {
        NSArray *req=[arr[i] componentsSeparatedByString:@"?"];
        NSString *s=req[0];
        if (s.length<=1) {
            continue;
        }
        [requetsDic setObject:s forKey:req[0]];
    }
    
    [sview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSArray *keys=[requetsDic allKeys];
    for (int i=0; i<keys.count; i++) {
        CC_TextField *t=[CC_TextField ccr:sview l:[ccui getRH:10] t:[ccui getRH:40]*i w:[ccui getRH:300] h:[ccui getRH:40] tc:[UIColor whiteColor] bgc:[UIColor blackColor] f:[UIFont systemFontOfSize:14] ta:0 ph:keys[i] uie:YES];
        t.text=keys[i];
        t.delegate=self;
    }
    sview.contentSize=CGSizeMake(sview.contentSize.width, [ccui getRH:40]*(keys.count));
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self endEdit];
}

- (void)clear{
    user_nameT.text=@"";
    user_psdT.text=@"";
    displayT.text=@"";
    [sview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

//- (void)request{
//    NSArray *arr=[[AppShare getInstance].cpStr componentsSeparatedByString:@";"];
////    __block NSString *allStr=[[NSString alloc]init];
//    __block NSMutableAttributedString *allStr=[[NSMutableAttributedString alloc]init];
//    __block ViewController *blockSelf=self;
//    for (int i=0; i<arr.count; i++) {
//        NSString *urlStr=arr[i];
//        NSString *reqS;
//        {//cut ?
//            NSArray *tempArr=[urlStr componentsSeparatedByString:@"?"];
//            if (tempArr.count<2) {
//                continue;
//            }
//            reqS=tempArr[0];
//            urlStr=tempArr[1];
//        }
//
//        NSString *service;
//        NSArray *keys=[urlStr componentsSeparatedByString:@"&"];
//        for (int m=0; m<keys.count; m++) {
//            NSArray *vs=[keys[m] componentsSeparatedByString:@"="];
//            if (vs.count>0) {
//                if ([vs[0]isEqualToString:@"service"]) {
//                    service=vs[1];
//                }
//            }
//        }
//        if ([service isEqualToString:@"USER_LOGIN"]) {
//            urlStr=ccstr(@"%@?%@",reqS,urlStr);
//            urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            [[CC_HttpTask getInstance]get:[NSURL URLWithString:urlStr] params:@{@"getDate":@""} model:[ResModel new] finishCallbackBlock:^(NSString *error, ResModel *model) {
//                if (error) {
//                    return ;
//                }
//                NSDictionary *result=model.resultDic;
//
//                NSString *signKey=result[@"response"][@"signKey"];
//                userId=result[@"response"][@"userId"];
//                loginKey=result[@"response"][@"loginKey"];
//                [[CC_HttpTask getInstance]setSignKeyStr:signKey];
//
//                [self requestAll];
//            }];
//            break;
//        }
//    }
//}

- (void)requestAll:(int)type{
    NSArray *arr=[[AppShare getInstance].cpStr componentsSeparatedByString:@";"];
    //    __block NSString *allStr=[[NSString alloc]init];
    __block NSMutableAttributedString *allStr=[[NSMutableAttributedString alloc]init];
    __block ViewController *blockSelf=self;
    
    for (int i=0; i<arr.count; i++) {
        NSString *urlStr=arr[i];
        NSString *reqS;
        if (urlStr.length<=1) {
            continue;
        }
        {//cut ?
            NSArray *tempArr=[urlStr componentsSeparatedByString:@"?"];
            if (tempArr.count<2) {
                continue;
            }
            reqS=tempArr[0];
            urlStr=tempArr[1];
        }
        NSString *service;
        NSArray *keys=[urlStr componentsSeparatedByString:@"&"];
        NSMutableDictionary *tempDic=[[NSMutableDictionary alloc]init];
        for (int m=0; m<keys.count; m++) {
            NSArray *vs=[keys[m] componentsSeparatedByString:@"="];
            if (vs.count>0) {
                if ([vs[0]isEqualToString:@"service"]) {
                    service=vs[1];
                }
                NSString *v1=vs[1];
                [tempDic setObject:v1 forKey:vs[0]];
                if (type==1) {
                    [tempDic setObject:loginKey forKey:@"loginKey"];
                    [tempDic setObject:userId forKey:@"authedUserId"];
                }
            }
        }
        if (type==0) {
            if ([service isEqualToString:@"USER_LOGIN"]) {
                if (user_nameT.text.length>0) {
                    [tempDic setObject:user_nameT.text forKey:@"cell"];
                    [tempDic setObject:user_nameT.text forKey:@"loginName"];
                }
                if (user_psdT.text.length>0) {
                    [tempDic setObject:user_psdT.text forKey:@"loginPassword"];
                }
                [[CC_HttpTask getInstance]setRequestHTTPHeaderFieldDic:
                 @{@"appName":@"iphone",
                   @"appVersion":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
                   }];
                __block ViewController *blockSelf=self;
                [[CC_HttpTask getInstance]post:[NSURL URLWithString:reqS] params:tempDic model:[ResModel new] finishCallbackBlock:^(NSString *error, ResModel *model) {
                    if (error) {
                        blockSelf->displayT.text=error;
                        return ;
                    }
                    NSDictionary *result=model.resultDic;
                    
                    NSString *signKey=result[@"response"][@"signKey"];
                    blockSelf->userId=result[@"response"][@"userId"];
                    blockSelf->loginKey=result[@"response"][@"loginKey"];
                    [[CC_HttpTask getInstance]setSignKeyStr:signKey];
                    
                    [self requestAll:1];
                }];
            }else{
                continue;
            }
        }
        if ([service isEqualToString:@"USER_LOGIN"]) {
            continue;
        }
//        urlStr=[[NSString alloc]init];
//        NSArray *tempKeys=[tempDic allKeys];
//        for (int m=0; m<tempKeys.count; m++) {
//            NSString *key=tempKeys[m];
//            urlStr=[urlStr stringByAppendingString:ccstr(@"%@=%@&",key,tempDic[key])];
//        }
//
//        urlStr=ccstr(@"%@%@",nameT.text,urlStr);
//        urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [tempDic removeObjectForKey:@"sign"];
        
        reqS=requetsDic[reqS];
        
        [[CC_HttpTask getInstance]post:[NSURL URLWithString:reqS] params:tempDic model:[ResModel new] finishCallbackBlock:^(NSString *error, ResModel *model) {
            if (blockSelf->allBt.selected) {
                allStr=[CC_AttributedStr getOrigAttStr:allStr appendStr:ccstr(@"service=%@\n",service) withColor:[UIColor greenColor]];
            }else{
                allStr=[CC_AttributedStr getOrigAttStr:allStr appendStr:ccstr(@"%@\n",model.requestStr) withColor:[UIColor greenColor]];
            }
            if (error) {
                NSString *getS=error;
                if (blockSelf->allBt.selected) {
                    if (getS.length>100) {
                        getS=[getS substringToIndex:100];
                        getS=[getS stringByAppendingString:@"..."];
                    }
                }
                if ([getS containsString:@"SYSTEM_ERROR"]) {
                    allStr=[CC_AttributedStr getOrigAttStr:allStr appendStr:getS withColor:[UIColor purpleColor] andFont:[UIFont systemFontOfSize:30]];
                }else if ([getS containsString:@"SIGN_ERROR"]) {
                    allStr=[CC_AttributedStr getOrigAttStr:allStr appendStr:getS withColor:[UIColor yellowColor]];
                }
                else{
                    allStr=[CC_AttributedStr getOrigAttStr:allStr appendStr:getS withColor:[UIColor redColor]];
                }
            }else{
                NSString *getS=model.resultStr;
                if (blockSelf->allBt.selected) {
                    if (getS.length>100) {
                        getS=[getS substringToIndex:100];
                        getS=[getS stringByAppendingString:@"..."];
                    }
                }
                allStr=[CC_AttributedStr getOrigAttStr:allStr appendStr:getS withColor:[UIColor greenColor]];
            }
            allStr=[CC_AttributedStr getOrigAttStr:allStr appendStr:@"\n\n" withColor:[UIColor greenColor]];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
            [allStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,allStr.length)];
            blockSelf->displayT.attributedText=allStr;
        }];
    }
}


@end
