//
//  XZHShareBase.m
//  ShareLib
//
//  Created by XiongZenghui on 15/6/30.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XZHShareBase.h"
#import <TMCache.h>
#import <UIKit/UIKit.h>


@implementation XZHShareBase 

- (void)saveOptions:(NSDictionary *)optionDict {
    NSParameterAssert(optionDict);
    
    [[TMCache sharedCache] setObject:optionDict forKey:[self platformName]];
}

- (NSDictionary *)optionDict {
    return [[TMCache sharedCache] objectForKey:[self platformName]];
}

+ (void)openURL:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (BOOL)canOpenURL:(NSString *)url {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

#pragma mark -

- (NSString *)platformName {
    return nil;
}

- (XZHSharePlatform)platformType {
    return XZHShareUndefine;
}

- (void)registWithAppIdOrAppKey:(NSString *)keyOrId
                      AppSecret:(NSString *)secret
{
    //override by subclass
}

- (void)startShare:(XZHMessage *)message Type:(XZHShareType)shareType {
    //override by subclass
}

- (BOOL)handleOpenURL
{
    //override by subclass
    return NO;
}



@end
