//
//  XZHShareMessage.h
//  ShareLib
//
//  Created by XiongZenghui on 15/6/29.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XZHMessageType) {
    XZHMessageText                  = 1,                //纯文本
    XZHMessageImage ,                                   //纯图片
    XZHMessageNews ,                                    //新闻
    XZHMessageAudio ,                                   //音频
    XZHMessageVideo ,                                   //视屏
    XZHMessageApp ,                                     //分享App
    XZHMessageFile ,                                    //文件
    XZHMessageLink ,                                    //链接（图片、标题、描述）
    XZHMessageUndefined ,                               //未知
};

@interface XZHMessage : NSObject

@property (nonatomic, assign) XZHMessageType messageType;//消息类型

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSData *thumbImageData;//缩略图像

//专用于微信分享的扩展字段
@property NSString* extInfo;
@property NSString* mediaDataUrl;
@property NSString* fileExt;

//Log属性-值
- (NSDictionary *)debug;

@end
