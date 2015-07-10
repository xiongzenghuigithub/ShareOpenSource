//
//  XZHShareInterface.h
//  ShareLib
//
//  Created by xiongzenghui on 15/6/28.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZHMessage.h"

typedef NS_ENUM(NSInteger, XZHSharePlatform) {
    XZHShareQQ                                  = 1,
    XZHShareSinaWeibo                           = 2,
    XZHShareWeixin                              = 3,
    XZHShareUndefine                            = 0x9999,
};

typedef NS_ENUM(NSInteger, XZHShareType) {
    XZHShareToQQFriend                  = 1,
    XZHShareToQZone,
    XZHShareToQQFavirate,
    XZHShareToQQDataLine ,
    
    XZHShareToWeixinSession,
    XZHShareToWeixinFriends,
    XZHShareToWeixinFavirate,
};


/**
 *  所有分享平台必须实现的规范
 */
@protocol XZHShareInterface <NSObject>

@required

- (NSString *)platformName;
- (XZHSharePlatform)platformType;
- (XZHMessageType)computeMessageType:(XZHMessage *)message;

//secret是可选
- (void)registWithAppIdOrAppKey:(NSString *)keyOrId
                      AppSecret:(NSString *)secret;

- (void)startShare:(XZHMessage *)message Type:(XZHShareType)shareType;

- (BOOL)handleOpenURL;

@optional
- (void)oauth;
- (BOOL)isInstalled;

@end
