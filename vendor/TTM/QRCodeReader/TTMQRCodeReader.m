//
//  TTMQRCodeReader.m
//  iOS7Sampler
//
//  Created by Shuichi Tsutsumi on 2015/04/08.
//  Copyright (c) 2015年 Shuichi Tsutsumi. All rights reserved.
//

#import "TTMQRCodeReader.h"
@import AVFoundation;


@interface TTMQRCodeReader ()
<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@end


@implementation TTMQRCodeReader

+ (instancetype)sharedReader {
    
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


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
        if ([self.delegate respondsToSelector:@selector(didDetectQRCode:)]) {
            [self.delegate didDetectQRCode:machineReadableCode];
        }
    }
}


// =============================================================================
#pragma mark - Private


// =============================================================================
#pragma mark - Public

- (void)startReaderOnView:(UIView *)view {
    
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
    captureVideoPreviewLayer.frame = view.bounds;
    
    [view.layer addSublayer:captureVideoPreviewLayer];
    
    [self.captureSession startRunning];
}

- (void)stopReader {
    
    [self.captureSession stopRunning];
}

@end
