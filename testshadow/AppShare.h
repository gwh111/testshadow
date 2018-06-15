//
//  AppShare.h
//  testshadow
//
//  Created by gwh on 2018/6/14.
//  Copyright © 2018年 gwh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppShare : NSObject

+ (instancetype)getInstance;

@property(nonatomic,retain) NSString *cpStr;

@end
