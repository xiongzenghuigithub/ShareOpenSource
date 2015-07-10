//
//  XZHShareToWeixin.m
//  ShareLib
//
//  Created by XiongZenghui on 15/7/8.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XZHShareToWeixin.h"
#import "XZHMessage.h"
#import "XZHShareManager.h"
#import <UIKit/UIKit.h>

static NSString *const Scheme = @"weixin://";

typedef NS_ENUM(NSInteger, XZHWeixinPlatform) {
    XZHWeixinPlatformSession    = 0,//会话
    XZHWeixinPlatformTimeline   = 1,//朋友圈
    XZHWeixinPlatformFavorite   = 2,//收藏
};

@implementation XZHShareToWeixin

- (BOOL)isInstalled {
    return [[self class] canOpenURL:Scheme];
}

- (NSString *)platformName {
    return @"weixin";
}

- (XZHSharePlatform)platformType {
    return XZHShareWeixin;
}

- (void)registWithAppIdOrAppKey:(NSString *)keyOrId
                      AppSecret:(NSString *)secret
{
    NSDictionary *option = @{@"appid" : keyOrId};
    [self saveOptions:option];
}

- (void)startShare:(XZHMessage *)message Type:(XZHShareType)shareType {
    NSString *url = @"";
    if (shareType == XZHShareToWeixinSession) {
        url = [self _generateShareUrl:message ForType:XZHWeixinPlatformSession];
    } else if (shareType == XZHShareToWeixinFriends) {
        url = [self _generateShareUrl:message ForType:XZHWeixinPlatformTimeline];
    } else if (shareType == XZHShareToWeixinFavirate) {
        url = [self _generateShareUrl:message ForType:XZHWeixinPlatformFavorite];
    }
    
    [[self class] openURL:url];
}

- (BOOL)handleOpenURL
{
    XZHShareManager *manager = [XZHShareManager manager];
    NSURL *url = manager.returnURL;
    if ([url.scheme hasPrefix:@"wx"]) {
        NSDictionary *returnDict = [[XZHShareManager manager] clipBoardLoadWithKey:@"content" Encoding:XZHClipBoardNSPropertyListSerialization];
        NSDictionary *dict = [returnDict objectForKey:[self optionDict][@"appid"]];
        if ([url.absoluteString rangeOfString:@"://oauth"].location != NSNotFound) {
            
        } else if ([url.absoluteString rangeOfString:@"://pay"].location != NSNotFound) {
            
        } else {
            if (dict[@"state"]&&[dict[@"state"] isEqualToString:@"Weixinauth"]&&[dict[@"result"] intValue]!=0) {
                //登录失败
            }else if([dict[@"result"] intValue]==0){
                //分享成功
                if (manager.onShareSuccess) {
                    manager.onShareSuccess(manager.shareMessage);
                }
            }else{
                //分享失败
                if (manager.onShareFail) {
                    manager.onShareFail(manager.shareMessage,[NSError errorWithDomain:@"weixin_share" code:[dict[@"result"] intValue] userInfo:dict]);
                }
            }

        }
        
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - tools

- (NSString*)_generateShareUrl:(XZHMessage *)msg ForType:(XZHWeixinPlatform)type
{
    NSMutableDictionary *params = [@{@"result":@"1",
                                     @"returnFromApp" :@"0",
                                     @"scene" : [NSString stringWithFormat:@"%ld",type],
                                     @"sdkver" : @"1.5"} mutableCopy];
    
    NSDictionary *subPrams = nil;
    
    
    if (msg.messageType == XZHMessageNews) {
        msg.messageType = 0;
    }
    
    if (!msg.messageType) {
        if ([self computeMessageType:msg] == XZHMessageText) {
            subPrams = @{
                         @"command" : @"1020",
                         @"title" : msg.title
                         };
        } else if ([self computeMessageType:msg] == XZHMessageImage) {
            subPrams = @{
                         @"command" : @"1010",
                         @"fileData" : msg.imageData,
                         @"thumbData" :msg.thumbImageData?:msg.imageData,
                         @"objectType" : @"2"
                         };
        } else if ([self computeMessageType:msg] == XZHMessageLink) {
            subPrams = @{
                         @"command" : @"1010",
                         @"title" : msg.title,
                         @"description" : msg.desc?:msg.title,
                         @"mediaUrl" : msg.link,
                         @"objectType" : @"5",
                         @"thumbData" : msg.thumbImageData?:msg.imageData,
                         };
        }
    } else {
        if (msg.messageType == XZHMessageAudio) {
            subPrams = @{
                         @"command" : @"1010",
                         @"description" : msg.desc?:msg.title,
                         @"mediaUrl" : msg.link,
                         @"mediaDataUrl" : msg.mediaDataUrl,
                         @"objectType" : @"3",
                         @"thumbData" : msg.thumbImageData?:msg.imageData,
                         @"title" : msg.title
                         };

        } else if (msg.messageType == XZHMessageVideo) {
            subPrams = @{
                         @"command" : @"1010",
                         @"description" : msg.desc?:msg.title,
                         @"mediaUrl" : msg.link,
                         @"objectType" : @"4",
                         @"thumbData" : msg.thumbImageData?:msg.imageData,
                         @"title" : msg.title
                         };
        } else if (msg.messageType == XZHMessageApp) {
            if(msg.extInfo) {
                subPrams = @{
                             @"command" : @"1010",
                             @"description" : msg.desc?:msg.title,
                             @"extInfo" : msg.extInfo,
                             @"fileData" : msg.imageData,
                             @"mediaUrl" : msg.link,
                             @"objectType" : @"7",
                             @"thumbData" : msg.thumbImageData?:msg.imageData,
                             @"title" : msg.title
                             };
            } else {
                subPrams = @{
                             @"command" : @"1010",
                             @"description" : msg.desc?:msg.title,
                             @"fileData" : msg.imageData,
                             @"mediaUrl" : msg.link,
                             @"objectType" : @"7",
                             @"thumbData" : msg.thumbImageData?:msg.imageData,
                             @"title" : msg.title
                             };
            }
            
        } else if (msg.messageType == XZHMessageFile) {
            subPrams = @{
                         @"command" : @"1010",
                         @"description" : msg.desc?:msg.title,
                         @"fileData" : msg.imageData,
                         @"fileExt" : msg.fileExt ? : @"",
                         @"objectType" : @"6",
                         @"thumbData" : msg.thumbImageData?:msg.imageData,
                         @"title" : msg.title
                         };
        }
    }
    
    [params addEntriesFromDictionary:subPrams];
    [[XZHShareManager manager] clipBoardSave:@{[self optionDict][@"appid"]:params}
                                      ForKey:@"content"
                                    Encoding:XZHClipBoardNSPropertyListSerialization];
    
    return [NSString stringWithFormat:@"weixin://app/%@/sendreq/?",[self optionDict][@"appid"]];
}

- (XZHMessageType)computeMessageType:(XZHMessage *)message {
    if (message.title && !message.imageData && !message.link) {
        return XZHMessageText;
    } else if (!message.link && message.imageData) {//纯图片
        return XZHMessageImage;
    } else if (message.title && message.link && message.imageData) {//有链接的图片分享
        return XZHMessageLink;
    }
    return XZHMessageUndefined;
}

@end
