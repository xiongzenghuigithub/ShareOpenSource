//
//  XZHShareToQQ.m
//  ShareLib
//
//  Created by xiongzenghui on 15/6/29.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XZHShareToQQ.h"
#import "XZHShareManager.h"


static NSString *const ShareCallbackSchemePrix      = @"QQ";
static NSString *const OauthCallbackSchemePrix      = @"tencent";

static NSString *const IsInstallSchema          = @"mqqapi://";
static NSString *const ChatSchema               = @"mqqwpa://im/chat";
static NSString *const OpenApiSchema            = @"mqqopensdkapi://";
static NSString *const SSOLoginSchema           = @"mqqOpensdkSSoLogin://";
static NSString *const ShareSchema              = @"mqqapi://share/to_fri";

typedef NS_ENUM(NSInteger, XZHTencentPlatform) {
    XZHTencentMobileQQ                  = 0x00,//QQ好友
    XZHTencentQZone                     = 0x01,//QQ空间
//    XZHTencentZoneShareForbid           = 0x02,
    XZHTencentQQShareFavorites          = 0x08, //收藏
    XZHTencentQQShareDataline           = 0x10,  //数据线
};

@implementation XZHShareToQQ

- (BOOL)isInstalled {
    return [[self class] canOpenURL:IsInstallSchema];
}

- (NSString *)platformName {
    return @"QQ";
}

- (XZHSharePlatform)platformType {
    return XZHShareQQ;
}

- (void)registWithAppIdOrAppKey:(NSString *)keyOrId AppSecret:(NSString *)secret {
    NSDictionary *options = @{
                              @"appid" : keyOrId,
                              @"callback_name" : [NSString stringWithFormat:@"QQ%02llx",[keyOrId longLongValue]]
                              };
    
    [self saveOptions:options];
}

- (void)startShare:(XZHMessage *)message Type:(XZHShareType)shareType
{
    NSString *url = @"";

    if (shareType == XZHShareToQZone) {
        url = [self _generateShareUrl:message ForType:XZHTencentQZone];
    } else if (shareType == XZHShareToQQFriend) {
        url = [self _generateShareUrl:message ForType:XZHTencentMobileQQ];
    } else if (shareType == XZHShareToQQFavirate) {
        url = [self _generateShareUrl:message ForType:XZHTencentQQShareFavorites];
    } else if (shareType == XZHShareToQQDataLine) {
        url = [self _generateShareUrl:message ForType:XZHTencentQQShareDataline];
    }
    
    [[self class] openURL:url];
}

- (BOOL)handleOpenURL {
    XZHShareManager *manager = [XZHShareManager manager];
    NSURL *returnURL = manager.returnURL;
    
    if ([returnURL.scheme hasPrefix:ShareCallbackSchemePrix]) {
        NSDictionary *dict = [XZHShareManager parseUrl:[XZHShareManager manager].returnURL];
        if ([dict hasKey:@"error_description"]) {
            [dict setValue:[XZHShareManager base64Decode:dict[@"error_description"]] forKey:@"error_description"];
        }
        if ([dict hasKey:@"error"]) {
            NSInteger code = [dict[@"error"] integerValue];
            if (code != 0) {
                NSError *error = [NSError errorWithDomain:@"response_from_qq" code:code userInfo:dict];
                if (manager.onShareFail) {
                    manager.onShareFail(manager.shareMessage, error);
                }
            }else {
                if (manager.onShareSuccess) {
                    manager.onShareSuccess(manager.shareMessage);
                }
            }
        }
        
        [manager clearCompletions];
        return YES;
    } else if ([returnURL.scheme hasPrefix:OauthCallbackSchemePrix]) {
        
        [manager clearCompletions];
        return YES;
    } else {
        
        [manager clearCompletions];
        return NO;
    }
}

#pragma mark - tools

- (NSString*)_generateShareUrl:(XZHMessage *)msg ForType:(XZHTencentPlatform)type {
    
    NSString *url = [[NSString alloc] initWithString:ShareSchema];
    
    NSString *boundleName = [XZHShareManager base64Encode:[XZHShareManager CFBundleDisplayName]];
    NSString *callback_name = [[self optionDict] objectForKey:@"callback_name"];
    
    NSMutableDictionary *params = [@{
                                    @"thirdAppDisplayName" : boundleName,
                                    @"version" : @"1",
                                    @"cflag" : [NSString stringWithFormat:@"%ld", type],
                                    @"callback_type" : @"scheme",
                                    @"generalpastboard" : @"1",
                                    @"callback_name" : callback_name,
                                    @"src_type" : @"app",
                                    @"shareType" : @"0",
                                    } mutableCopy];
    
    if (msg.link && !msg.messageType) {
        msg.messageType = XZHMessageNews;
    }
    
    NSDictionary *subParams = nil;
    
    if ([self computeMessageType:msg] == XZHMessageText) {
        
        NSString *fileData = [XZHShareManager base64AndUrlEncode:msg.title];
        subParams = @{
                      @"file_type" : @"text",
                      @"file_data" : fileData
                      };
        
    } else if ([self computeMessageType:msg] == XZHMessageImage) {
        
        NSDictionary *data=@{
                             @"file_data":msg.imageData,
                             @"previewimagedata":msg.thumbImageData?:msg.imageData
                             };
        //将图像保存到剪贴板
        [[XZHShareManager manager] clipBoardSave:data
                                          ForKey:SaveObjectForQQPlatformKey
                                        Encoding:XZHClipBoardNSKeyedArchiver];
        
        NSString *title = [XZHShareManager base64AndUrlEncode:msg.title];
        NSString *desc = [XZHShareManager base64AndUrlEncode:msg.desc];
        subParams = @{
                      @"file_type" : @"img",
                      @"title" : title,
                      @"objectlocation" : @"pasteboard",
                      @"description" : desc,
                      };
        
    }else if ([self computeMessageType:msg] == XZHMessageNews) {
        
        NSDictionary *data=@{@"previewimagedata":msg.imageData};
        
        //将图像保存到剪贴板
        [[XZHShareManager manager] clipBoardSave:data
                                          ForKey:SaveObjectForQQPlatformKey
                                        Encoding:XZHClipBoardNSKeyedArchiver];
        
        NSString *title = [XZHShareManager base64AndUrlEncode:msg.title];
        NSString *url = [XZHShareManager base64AndUrlEncode:msg.link];
        NSString *desc = [XZHShareManager base64AndUrlEncode:msg.desc];
        
        NSString *msgType=@"news";
        if (msg.messageType == XZHMessageNews) {
            msgType = @"news";
        } else if (msg.messageType == XZHMessageAudio) {
            msgType = @"audio";
        }
        
        subParams = @{
                      @"file_type" : msgType,
                      @"title" : title,
                      @"url" : url,
                      @"description" : desc,
                      @"objectlocation" : @"pasteboard",
                      };
    }
    
    [params addEntriesFromDictionary:subParams];
    
    url = [XZHShareManager urlStringWithOriginUrlString:url appendParameters:params];
    
    return url;
}

- (XZHMessageType)computeMessageType:(XZHMessage *)message {
    
    if (message.title && (!message.link && !message.imageData)) {//分享纯文本消息
        return XZHMessageText;
    }
    else if (!message.link && (message.title && message.imageData && message.desc)) {//分享图片消息
        return XZHMessageImage;
    }
    else if (message.title && message.desc && message.imageData && message.link && message.messageType) {
        //新闻／多媒体分享（图片加链接）发送新闻消息 预览图像数据，最大1M字节 URL地址,必填，最长512个字符 via QQApiInterfaceObject.h
        return XZHMessageNews;
    }
    
    return XZHMessageUndefined;
}

#pragma mark - Tool 

- (NSString *)convertHexAppId {
    int a = 1103289287 ;
    NSString *str = [ [NSString alloc] initWithFormat:@"%X",a];
    return str;
}


@end

