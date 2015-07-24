//
//  ViewController.m
//  ShareLib
//
//  Created by XiongZenghui on 15/6/26.
//  Copyright (c) 2015年 XiongZenghui. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>

#import "XZHShareManager.h"

static NSString *const cellId = @"cellid";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, strong) UIImagePickerController *pickerVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(20);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    _dataList = @[@"分享Text到QQ空间", @"分享Image到QQ空间", @"分享Text到微信朋友圈", @"分享到微信会话"];
    
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    cell.detailTextLabel.text = _dataList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    
    switch (row) {
        case 0: {
            [self shareToQQ];
        }
            break;
        case 1: {
            [self shareToQZoneWithImage];
        }
            break;
        case 2: {
            [self shareToWeixinTimelineWithText];
        }
            break;
        case 3: {
            [self shareToWeixinSession];
        }
            break;
    }
}

- (void)shareToQQ {
    [self shareToQZoneWithText];
}

//纯文本消息，分享到QQ空间
- (void)shareToQZoneWithText {
    
    XZHMessage *message = [[XZHMessage alloc] init];
    message.title = @"纯文本消息分享到QQ空间";
    
    [[XZHShareManager manager] shareMessage:message
                                   Platform:XZHShareQQ
                                       Type:XZHShareToQZone
                                  OnSuccess:^(XZHMessage *message)
    {
        
    } OnFail:^(XZHMessage *message, NSError *error) {
        
    }];
}

//图像，分享到QQ
- (void)shareToQZoneWithImage {
    
    _pickerVC = [[UIImagePickerController alloc] init];
    _pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _pickerVC.delegate = self;
    _pickerVC.allowsEditing = YES;
    [self presentViewController:_pickerVC animated:YES completion:^{
        
    }];
}

- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    
    //分享图片信息到QQ空间
//    XZHMessage *message = [[XZHMessage alloc] init];
//    message.title = @"分享图片到QQ空间";
//    message.desc = @"这是图像的描述....";
//    message.link = @"http://www.baidu.com";
//    message.imageData = UIImagePNGRepresentation(image);
//    message.thumbImageData = UIImagePNGRepresentation(image);
//    
//    [[XZHShareManager manager] shareMessage:message Platform:XZHShareQQ Type:XZHShareToQZone OnSuccess:^(XZHMessage *message) {
//        
//    } OnFail:^(XZHMessage *message, NSError *error) {
//        
//    }];
    
    //1. 分享图片信息到微信会话
    XZHMessage *message = [[XZHMessage alloc] init];
    message.title = @"分享到微信会话";
    message.desc = @"这是描述.... ";
    message.link = @"www.baidu.com";
    message.imageData = UIImageJPEGRepresentation(image, 0.1);
    message.thumbImageData = UIImageJPEGRepresentation(image, 0.1);
    
    //2. 分享
    [[XZHShareManager manager] shareMessage:message
                                   Platform:XZHShareWeixin
                                       Type:XZHShareToWeixinSession
                                  OnSuccess:^(XZHMessage *message) {
        
                                  } OnFail:^(XZHMessage *message, NSError *error) {
        
                                  }];
    
    [self dismissViewControllerAnimated:YES completion:^(){
        
    }];
}

- (void)shareToWeixinTimelineWithText {
    XZHMessage *message = [[XZHMessage alloc] init];
    message.title = @"纯文本消息分享到微信朋友圈";

    [[XZHShareManager manager] shareMessage:message
                                   Platform:XZHShareWeixin
                                       Type:XZHShareToWeixinFriends
                                  OnSuccess:^(XZHMessage *message) {
        
    } OnFail:^(XZHMessage *message, NSError *error) {
        
    }];
}

- (void)shareToWeixinSession {

    _pickerVC = [[UIImagePickerController alloc] init];
    _pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _pickerVC.delegate = self;
    _pickerVC.allowsEditing = YES;
    [self presentViewController:_pickerVC animated:YES completion:^{
        
    }];
}

@end
