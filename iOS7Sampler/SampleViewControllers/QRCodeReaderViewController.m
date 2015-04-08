//
//  QRCodeReaderViewController.m
//  iOS7Sampler
//
//  Created by Shuichi Tsutsumi on 2015/04/08.
//  Copyright (c) 2015年 Shuichi Tsutsumi. All rights reserved.
//

#import "QRCodeReaderViewController.h"
#import "SVProgressHUD.h"
#import "TTMQRCodeReader.h"
#import <AVFoundation/AVMetadataObject.h>


@interface QRCodeReaderViewController ()
<TTMQRCodeReaderDelegate>
@end


@implementation QRCodeReaderViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[TTMQRCodeReader sharedReader] setDelegate:self];
    [[TTMQRCodeReader sharedReader] startReaderOnView:self.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


// =============================================================================
#pragma mark - TTMQRCodeReaderDelegate

- (void)didDetectQRCode:(AVMetadataMachineReadableCodeObject *)qrCode {
    
    NSString *msg = [NSString stringWithFormat:@"Detected a QR code! type:%@, value:%@",
                     qrCode.type, qrCode.stringValue];
    [SVProgressHUD showSuccessWithStatus:msg];
}

@end
