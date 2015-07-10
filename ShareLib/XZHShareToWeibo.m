//
//  XZHShareToWeibo.m
//  ShareLib
//
//  Created by XiongZenghui on 15/7/8.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XZHShareToWeibo.h"

static NSString *const Scheme = @"Weibo";

@implementation XZHShareToWeibo

- (BOOL)isInstalled {
    return [[self class] canOpenURL:@"weibosdk://request"];
}

- (NSString *)platformName {
    return Scheme;
}

- (XZHSharePlatform)platformType {
    return XZHShareSinaWeibo;
}

- (void)registWithAppIdOrAppKey:(NSString *)keyOrId
                      AppSecret:(NSString *)secret
{
    NSDictionary *option = @{@"appid" : keyOrId};
    [self saveOptions:option];
}

- (void)startShare:(XZHMessage *)message Type:(XZHShareType)shareType {
    if ([self computeMessageType:message] == XZHMessageText) {
        
    } else if ([self computeMessageType:message] == XZHMessageImage) {
        
    } else if ([self computeMessageType:message] == XZHMessageLink) {
        
    }
}

- (BOOL)handleOpenURL
{
    
    return NO;
}

- (XZHMessageType)computeMessageType:(XZHMessage *)message {
    if (!message.link && !message.imageData && message.title) {
        return XZHMessageText;
    } else if (!message.link && message.imageData && message.title) {
        return XZHMessageImage;
    } else if (message.link && message.imageData && message.title) {
        return XZHMessageLink;
    }
    return XZHMessageUndefined;
}

#pragma mark - tools

- (NSString*)_generateShareUrl:(XZHMessage *)msg {
    return nil;
}

@end
