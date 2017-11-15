//
//  ViewController.m
//  ios-demo-ftp
//
//  Created by WangDongya on 2017/11/14.
//  Copyright © 2017年 example. All rights reserved.
//

#import "ViewController.h"
#import "SCRFTPRequest.h"
#import <Masonry.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SCRFTPRequestDelegate>
{
    SCRFTPRequest *ftpRequest;
    NSString *filePath;
}

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *getImgBtn;
@property (nonatomic, strong) UIButton *sendImgBtn;

@property (nonatomic, strong) UIImagePickerController *pickerCtrl;

@end

@implementation ViewController

- (UIImagePickerController *)pickerCtrl
{
    if (!_pickerCtrl) {
        _pickerCtrl = [[UIImagePickerController alloc] init];
        _pickerCtrl.delegate = self;
        _pickerCtrl.allowsEditing = YES;
    }
    return _pickerCtrl;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.layer.borderWidth = 1;
        _imgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _imgView.layer.cornerRadius = 5;
        _imgView.clipsToBounds = YES;
    }
    return _imgView;
}

- (UIButton *)getImgBtn
{
    if (!_getImgBtn) {
        _getImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getImgBtn setTitle:@"获取图片" forState:UIControlStateNormal];
        [_getImgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_getImgBtn addTarget:self action:@selector(eventGetImg) forControlEvents:UIControlEventTouchUpInside];
        _getImgBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _getImgBtn.layer.borderWidth = 1;
        _getImgBtn.layer.cornerRadius = 5;
        _getImgBtn.clipsToBounds = YES;
    }
    return _getImgBtn;
}

- (UIButton *)sendImgBtn
{
    if (!_sendImgBtn) {
        _sendImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendImgBtn setTitle:@"FTP上传" forState:UIControlStateNormal];
        [_sendImgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sendImgBtn addTarget:self action:@selector(eventFtpSend) forControlEvents:UIControlEventTouchUpInside];
        _sendImgBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _sendImgBtn.layer.borderWidth = 1;
        _sendImgBtn.layer.cornerRadius = 5;
        _sendImgBtn.clipsToBounds = YES;
    }
    return _sendImgBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加载视图
    [self initViews];
}

- (void)initViews
{
    
    int width = [UIScreen mainScreen].bounds.size.width;
    
    [self.view addSubview:self.imgView];
    [self.view addSubview:self.getImgBtn];
    [self.view addSubview:self.sendImgBtn];
    
    // Masonry配置约束
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.view).offset(80);
        // 约束：高度 = 宽度
        make.height.equalTo(self.imgView.mas_width);
    }];
    
    [self.getImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(self.imgView.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(30);
        
        make.width.mas_equalTo(width/3);
        make.height.mas_equalTo(45);
    }];
    
    [self.sendImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(self.imgView.mas_bottom).offset(30);
        make.right.equalTo(self.view).offset(-30);

        make.width.mas_equalTo(width/3);
        make.height.mas_equalTo(45);
    }];
    
}

- (void)eventGetImg
{
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"读取相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 设置为相册
        self.pickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        // 获取图片
        [self presentViewController:self.pickerCtrl animated:YES completion:nil];
    }]];
    
    // 判断相机是否可用
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear|
         UIImagePickerControllerCameraDeviceFront]) {
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
    }
    
    // 添加取消操作
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)eventFtpSend
{
    
    if (!filePath) {  // 如果图片路径为空，则先选择图片
        [self eventGetImg];
        return;
    }
    
    // FTP请求对象初始化时，需ftp地址、文件
    ftpRequest = [[SCRFTPRequest alloc] initWithURL:[NSURL URLWithString:@"ftp://192.168.1.121/Desktop"] toUploadFile:filePath];
    ftpRequest.username = @"username";
    ftpRequest.password = @"password";
    ftpRequest.delegate = self;
    
    // 请求上传
    [ftpRequest startRequest];
}

// 处理需要上传的图片
- (void)handleImage:(UIImage *)img
{
    filePath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingString:@"Documents/protraitPic"], @"test_portrait.jpg"];
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingString:@"Documents/protraitPic"] isDirectory:&isDir] || isDir == NO) {
        // 创建路径
        [fileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingString:@"Documents/protraitPic"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 存储到沙盒
    // 获取图片数据
    NSData *imgData = UIImageJPEGRepresentation(img, 1);
    // 创建文件，并将图片数据存储到文件中
    [fileManager createFileAtPath:filePath contents:imgData attributes:nil];
}

#pragma mark - SCRFTPRequestDelegate
/** Called on the delegate when the request completes successfully. */
- (void)ftpRequestDidFinish:(SCRFTPRequest *)request
{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    filePath = nil;
}
/** Called on the delegate when the request fails. */
- (void)ftpRequest:(SCRFTPRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error : %@", error);
}
/** Called on the delegate when the transfer is about to start. */
- (void)ftpRequestWillStart:(SCRFTPRequest *)request
{
    NSLog(@"ftpRequestWillStart");
}
/** Called on the delegate when the status of the request instance changed. */
- (void)ftpRequest:(SCRFTPRequest *)request didChangeStatus:(SCRFTPRequestStatus)status
{
    NSLog(@"didChangeStatus");
}
/** Called on the delegate when some amount of bytes were transferred. */
- (void)ftpRequest:(SCRFTPRequest *)request didWriteBytes:(NSUInteger)bytesWritten
{
    NSLog(@"didWriteBytes : %lu", bytesWritten);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:picker completion:nil];
    
    // 获取原始图片，并显示到界面上
    self.imgView.image = info[UIImagePickerControllerOriginalImage];
    
    // 处理获取的图片，以便上传
    [self handleImage:self.imgView.image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:picker completion:nil];
}

@end
