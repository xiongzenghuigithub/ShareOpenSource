//
//  XZHShareManager.m
//  ShareLib
//
//  Created by xiongzenghui on 15/6/28.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "XZHShareManager.h"

#import <UIKit/UIKit.h>
#import <TMCache.h>

#import "XZHShareToQQ.h"
#import "XZHShareToWeixin.h"

NSString *const SaveObjectForQQPlatformKey = @"com.tencent.mqq.api.apiLargeData";

static NSString *CacheName = @"XZHShareLib";

@interface XZHShareManager ()

@property (nonatomic, strong) XZHShareToQQ *shareToQQ;
@property (nonatomic, strong) XZHShareToWeixin *shareToWeixin;

@end

@implementation XZHShareManager

+ (instancetype)manager {
    static XZHShareManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XZHShareManager alloc] init];
    });
    return manager;
}

+ (NSString *)rootPath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return docPath;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _setupAllPlatforms];
    }
    return self;
}

- (void)_setupAllPlatforms {
    _platforms = [NSMutableArray array];
    
    //QQ平台初始化
    _shareToQQ = [[XZHShareToQQ alloc] init];
    [_shareToQQ registWithAppIdOrAppKey:@"1103289287" AppSecret:@""];
    [_platforms addObject:_shareToQQ];
    
    //Weixin平台初始化
    _shareToWeixin = [[XZHShareToWeixin alloc] init];
    [_shareToWeixin registWithAppIdOrAppKey:@"wxd930ea5d5a258f4f" AppSecret:@""];
    [_platforms addObject:_shareToWeixin];
}


- (BOOL)handleOpenURL:(NSURL *)url {
    self.returnURL = url;
    
    //轮询所有分享平台，看哪个能处理
    for (id<XZHShareInterface> impl in self.platforms) {
        if ([impl handleOpenURL]) {
            return YES;
        }
    }
    return NO;
}

- (void)clearCompletions {
    _onShareSuccess = nil;
    _onShareFail = nil;
    _onAuthSuccess = nil;
    _onAuthFail = nil;
}

+(NSMutableDictionary *)parseUrl:(NSURL*)url{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSRange range=[keyValuePair rangeOfString:@"="];
        [queryStringDictionary setObject:range.length>0?[keyValuePair substringFromIndex:range.location+1]:@"" forKey:(range.length?[keyValuePair substringToIndex:range.location]:keyValuePair)];
    }
    return queryStringDictionary;
}

+(NSString*)base64Encode:(NSString *)input{
    return  [[input dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

+(NSString*)base64Decode:(NSString *)input{
    return [[NSString alloc ] initWithData:[[NSData alloc] initWithBase64EncodedString:input options:0] encoding:NSUTF8StringEncoding];
}

+(NSString*)CFBundleDisplayName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+(NSString*)CFBundleIdentifier{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+(NSString*)base64AndUrlEncode:(NSString *)string{
    return  [[self base64Encode:string] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

+(NSString*)urlDecode:(NSString*)input{
    return [[input stringByReplacingOccurrencesOfString:@"+" withString:@" "]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (UIImage *)screenshot
{
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)clipBoardSave:(id)value
               ForKey:(NSString *)key
             Encoding:(XZHClipBoardEncoding)encoding
{
    if (value && key) {
        
        NSData *encodedData = nil;
        NSError *error = nil;
        
        switch (encoding) {
                
            case XZHClipBoardNSKeyedArchiver: {
                encodedData = [NSKeyedArchiver archivedDataWithRootObject:value];
            }
                break;
                
            case XZHClipBoardNSPropertyListSerialization: {
                encodedData = [NSPropertyListSerialization dataWithPropertyList:value format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
                
            }
                break;
        }
        
        if (error) {
            NSLog(@"error when NSPropertyListSerialization: %@",error);
        } else if (encodedData) {
            [[UIPasteboard generalPasteboard] setData:encodedData forPasteboardType:key];
        }
    }
}

- (NSDictionary *)clipBoardLoadWithKey:(NSString *)key Encoding:(XZHClipBoardEncoding)encoding {
    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:key];
    NSDictionary *plist = nil;
    NSError *error = nil;
    
    if (data) {
        
        switch (encoding) {
            case XZHClipBoardNSKeyedArchiver: {
                plist = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
                break;
                
            case XZHClipBoardNSPropertyListSerialization: {
                plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:&error];
            }
                break;
        }
        
        if (error) {
            return nil;
        } else if (plist) {
            return plist;
        }
    }
    
    return nil;
}

#pragma mark -

- (id<XZHShareInterface>)_getImpl:(XZHSharePlatform)platform {
    if (platform == XZHShareQQ) {
        return _shareToQQ;
    } else if (platform == XZHShareWeixin) {
        return _shareToWeixin;
    } else if (platform == XZHShareSinaWeibo) {
        return nil;
    }
    return nil;
}

- (void)shareMessage:(id)message
            Platform:(XZHSharePlatform)platform
                Type:(XZHShareType)type
           OnSuccess:(void (^)(XZHMessage *message))success
              OnFail:(void (^)(XZHMessage *message, NSError *error))fail
{
    id<XZHShareInterface> impl = [self _getImpl:platform];
    
    if (!impl) {
        NSLog(@"请先注册对应分享平台的APPKey，并加入到数组维护!\n");
        return;
    }

    if ([[TMCache sharedCache] objectForKey:[impl platformName]])
    {
        self.onShareSuccess = [success copy];
        self.onShareFail = [fail copy];
        self.shareMessage = message;
        
        [impl startShare:message Type:type];
        
    } else {
        NSLog(@"请先注册APPKey，再进行分享!\n");

    }
}

+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters {
    NSString *filteredUrl = originUrlString;
    NSString *paraUrlString = [self urlParametersStringFromParameters:parameters];
    if (paraUrlString && paraUrlString.length > 0) {
        if ([originUrlString rangeOfString:@"?"].location != NSNotFound) {
            filteredUrl = [filteredUrl stringByAppendingString:paraUrlString];
        } else {
            filteredUrl = [filteredUrl stringByAppendingFormat:@"?%@", [paraUrlString substringFromIndex:1]];
        }
        return filteredUrl;
    } else {
        return originUrlString;
    }
}

+ (NSString *)urlParametersStringFromParameters:(NSDictionary *)parameters {
    NSMutableString *urlParametersString = [[NSMutableString alloc] initWithString:@""];
    if (parameters && parameters.count > 0) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            value = [NSString stringWithFormat:@"%@",value];
            value = [self urlEncode:value];
            [urlParametersString appendFormat:@"&%@=%@", key, value];
        }
    }
    return urlParametersString;
}

+ (NSString*)urlEncode:(NSString*)str {
    //different library use slightly different escaped and unescaped set.
    //below is copied from AFNetworking but still escaped [] as AF leave them for Rails array parameter which we don't use.
    //https://github.com/AFNetworking/AFNetworking/pull/555
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)str, CFSTR("."), CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
    return result;
}

@end
