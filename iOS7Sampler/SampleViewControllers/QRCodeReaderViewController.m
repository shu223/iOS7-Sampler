//
//  QRCodeReaderViewController.m
//  iOS7Sampler
//
//  Created by Shuichi Tsutsumi on 2015/04/08.
//  Copyright (c) 2015年 Shuichi Tsutsumi. All rights reserved.
//

#import "QRCodeReaderViewController.h"
@import AVFoundation;
#import "SVProgressHUD.h"


@interface QRCodeReaderViewController ()
<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
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
    
    [self startReader];
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
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)       captureOutput:(AVCaptureOutput *)captureOutput
    didOutputMetadataObjects:(NSArray *)metadataObjects
              fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadataObject in metadataObjects) {
        
        if (![metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            continue;
        }
        
        AVMetadataMachineReadableCodeObject *machineReadableCode = (AVMetadataMachineReadableCodeObject *)metadataObject;
        NSString *msg = [NSString stringWithFormat:@"Detected a QR code! type:%@, value:%@",
                         machineReadableCode.type, machineReadableCode.stringValue];
        [SVProgressHUD showSuccessWithStatus:msg];
    }
    
    [self stopReader];
}


// =============================================================================
#pragma mark - Private

- (void)startReader {

    // Find rear camera
    NSError *error;
    AVCaptureDevice *captureDevice;
    for (AVCaptureDevice *aCaptureDevice in [AVCaptureDevice devices]) {
        if (aCaptureDevice.position == AVCaptureDevicePositionBack) {
            captureDevice = aCaptureDevice;
        }
    }
    if (!captureDevice) {
        NSLog(@"Couldn't find rear camera.");
        return;
    }

    // Create AVCaptureDeviceInput object
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"error:%@", error);
        return;
    }
    
    // Create capture session and add an input to the session
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    if ([self.captureSession canAddInput:captureDeviceInput]) {
        [self.captureSession addInput:captureDeviceInput];
    }
    
    // Create capture metadata output and add to the session
    self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    if ([self.captureSession canAddOutput:self.captureMetadataOutput]) {
        [self.captureSession addOutput:self.captureMetadataOutput];
    }
    
    // Set target metadata object types
    self.captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];

    // Setup preview layer
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;// AVLayerVideoGravityResizeAspect is default.
    captureVideoPreviewLayer.bounds = CGRectMake(0, 0, 200, 200);
    captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    captureVideoPreviewLayer.borderWidth = 1.0f;
    captureVideoPreviewLayer.borderColor = [UIColor redColor].CGColor;
    
    [self.view.layer addSublayer:captureVideoPreviewLayer];
    
    [self.captureSession startRunning];
}

- (void)stopReader {

    [self.captureSession stopRunning];
}

@end
