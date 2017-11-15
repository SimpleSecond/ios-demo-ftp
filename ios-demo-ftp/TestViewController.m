//
//  TestViewController.m
//  ios-demo-ftp
//
//  Created by WangDongya on 2017/11/15.
//  Copyright © 2017年 example. All rights reserved.
//

#import "TestViewController.h"
#import <Masonry.h>
#import "SCRFTPRequest.h"

@interface TestViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    SCRFTPRequestDelegate>
{
    SCRFTPRequest *ftpRequest;
    NSString *filePath;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *sendImageBtn;
@property (nonatomic, strong) UIImagePickerController *pickerCtrl;


@end

@implementation TestViewController

-(UIImagePickerController *)pickerCtrl
{
    if (!_pickerCtrl) {
        _pickerCtrl = [[UIImagePickerController alloc] init];
        _pickerCtrl.allowsEditing = YES;
        _pickerCtrl.delegate = self;
    }
    return _pickerCtrl;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.borderColor = [UIColor redColor].CGColor;
        _imageView.layer.borderWidth = 1;
        _imageView.layer.cornerRadius = 5;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

-(UIButton *)sendImageBtn
{
    if (!_sendImageBtn) {
        _sendImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendImageBtn.layer.borderColor = [UIColor greenColor].CGColor;
        _sendImageBtn.layer.borderWidth = 1;
        _sendImageBtn.layer.cornerRadius = 10;
        _sendImageBtn.clipsToBounds = YES;
        [_sendImageBtn setTitle:@"获取图片并FTP发送" forState:UIControlStateNormal];
        [_sendImageBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_sendImageBtn addTarget:self action:@selector(sendImageEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendImageBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initViews
{
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.sendImageBtn];
    
    // 图片约束
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(80);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        
        make.height.equalTo(self.imageView.mas_width);
    }];
    
    // 按钮约束
    [self.sendImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        // 上边距，距图片底部偏移30
        make.topMargin.equalTo(self.imageView.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        
        make.height.mas_equalTo(45);
    }];
    
}


- (void)sendImageEvent
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 图库选项
    [alertCtrl addAction: [UIAlertAction actionWithTitle:@"图库" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.pickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.pickerCtrl animated:true completion:nil];
    }]];
    
    // 摄像头选项
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear|UIImagePickerControllerCameraDeviceFront]) {
        [alertCtrl addAction: [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            self.pickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.pickerCtrl animated:YES completion:nil];
        }]];
    }
    
    // 取消
    [alertCtrl addAction: [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

// 处理图片数据并上传
- (void)handleImage:(UIImage *)img
{
    // 给出文件路径
    filePath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingString:@"Dcouments/my_portraits"], @"test-portait.jpg"];
    
    // 判断路径是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingString:@"Dcouments/my_portraits"] isDirectory:&isDir] || !isDir) {
        // 创建路径
        [fileManager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingString:@"Dcouments/my_portraits"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 图片转成NSData数据
    NSData *imageData = UIImageJPEGRepresentation(img, 1);  // 不压缩的图片
    
    // 创建图片文件，并写入数据
    [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
    
    
    // 上传操作
    ftpRequest = [SCRFTPRequest requestWithURL:[NSURL URLWithString:@"ftp://"] toUploadFile:filePath];
    ftpRequest.username = @"";
    ftpRequest.password = @"";
    ftpRequest.delegate = self;
    // 开始上传
    [ftpRequest startRequest];
}

#pragma mark - SCRFTPRequestDelegate

/** Called on the delegate when the request completes successfully. */
- (void)ftpRequestDidFinish:(SCRFTPRequest *)request
{
    // 上传完成后，需将源文件清除
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
}
/** Called on the delegate when the request fails. */
- (void)ftpRequest:(SCRFTPRequest *)request didFailWithError:(NSError *)error
{
    
}

// @optional
/** Called on the delegate when the transfer is about to start. */
- (void)ftpRequestWillStart:(SCRFTPRequest *)request
{
    
}
/** Called on the delegate when the status of the request instance changed. */
- (void)ftpRequest:(SCRFTPRequest *)request didChangeStatus:(SCRFTPRequestStatus)status
{
    // 上传过程中的各种状态的变化
}
/** Called on the delegate when some amount of bytes were transferred. */
- (void)ftpRequest:(SCRFTPRequest *)request didWriteBytes:(NSUInteger)bytesWritten
{
    // 写入(上传)文件的大小
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 移除pickerCtrl
    [self dismissViewControllerAnimated:self.pickerCtrl completion:nil];
    
    // 获取图片资源
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // 显示图片
    self.imageView.image = image;
    
    // 处理图片数据，并上传
    [self handleImage:image];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:self.pickerCtrl completion:nil];
}


@end
