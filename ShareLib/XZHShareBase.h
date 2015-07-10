//
//  XZHShareBase.h
//  ShareLib
//
//  Created by XiongZenghui on 15/6/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZHShareInterface.h"
#import <NSDictionary+ObjectiveSugar.h>

@interface XZHShareBase : NSObject <XZHShareInterface>


- (void)saveOptions:(NSDictionary *)optionDict;
- (NSDictionary *)optionDict;

+ (void)openURL:(NSString *)url;
+ (BOOL)canOpenURL:(NSString *)url;

@end
