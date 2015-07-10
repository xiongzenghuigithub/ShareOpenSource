//
//  XZHShareManager.h
//  ShareLib
//
//  Created by xiongzenghui on 15/6/28.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZHShareInterface.h"

FOUNDATION_EXPORT NSString *const SaveObjectForQQPlatformKey;

//目前剪贴板只支持以下两种类型
typedef NS_ENUM(NSInteger, XZHClipBoardEncoding) {
    XZHClipBoardNSKeyedArchiver = 1,
    XZHClipBoardNSPropertyListSerialization ,
};

@interface XZHShareManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *platforms;
@property (nonatomic, strong) XZHMessage *shareMessage;
@property (strong, nonatomic) NSURL *returnURL;
@property (strong, nonatomic) NSDictionary *returnJSON;

@property (nonatomic, strong) void (^onShareSuccess)(XZHMessage *message);
@property (nonatomic, strong) void (^onShareFail)(XZHMessage *message, NSError *error);
@property (nonatomic, strong) void (^onAuthSuccess)(NSDictionary *dict);
@property (nonatomic, strong) void (^onAuthFail)(NSDictionary *dict, NSError *error);

+ (instancetype)manager;

/**
 *  分享
 *
 *  @param message  消息
 *  @param platform 平台
 *  @param type     类型
 */
- (void)shareMessage:(id)message
            Platform:(XZHSharePlatform)platform
                Type:(XZHShareType)type
           OnSuccess:(void (^)(XZHMessage *message))success
              OnFail:(void (^)(XZHMessage *message, NSError *error))fail;

- (void)authWithSuccess:(void (^)(NSDictionary *dict))success
                   Fail:(void (^)(NSDictionary *dict, NSError *error))fail;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)clipBoardSave:(id)data ForKey:(NSString *)key Encoding:(XZHClipBoardEncoding)encoding;
- (NSDictionary *)clipBoardLoadWithKey:(NSString *)key Encoding:(XZHClipBoardEncoding)encoding;

+ (NSString*)base64Encode:(NSString *)input;
+ (NSString*)base64Decode:(NSString *)input;
+ (NSString*)CFBundleDisplayName;
+ (NSString*)CFBundleIdentifier;
+ (NSString*)base64AndUrlEncode:(NSString *)string;
+ (NSString*)urlDecode:(NSString*)input;
+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters;
+ (NSMutableDictionary *)parseUrl:(NSURL*)url;

- (void)clearCompletions;

@end
