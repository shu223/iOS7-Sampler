//
//  SloMoVideoRecordViewController.m
//  https://github.com/shu223/SlowMotionVideoRecorder
//
//  Created by shuichi on 1/5/14.
//  Copyright (c) 2014 Shuichi Tsutsumi. All rights reserved.
//

#import "SloMoVideoRecordViewController.h"
#import "SVProgressHUD.h"
#import "TTMCaptureManager.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface SloMoVideoRecordViewController ()
<TTMCaptureManagerDelegate>
{
    NSTimeInterval startTime;
    BOOL isNeededToSave;
}
@property (nonatomic, strong) TTMCaptureManager *captureManager;
@property (nonatomic, assign) NSTimer *timer;
@property (nonatomic, strong) UIImage *recStartImage;
@property (nonatomic, strong) UIImage *recStopImage;
@property (nonatomic, strong) UIImage *outerImage1;
@property (nonatomic, strong) UIImage *outerImage2;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *fpsControl;
@property (nonatomic, weak) IBOutlet UIButton *recBtn;
@property (nonatomic, weak) IBOutlet UIImageView *outerImageView;
@end


@implementation SloMoVideoRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleDoubleTap:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
    
    // Setup images for the Shutter Button
    UIImage *image;
    image = [UIImage imageNamed:@"ShutterButtonStart"];
    self.recStartImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.recBtn setImage:self.recStartImage
                 forState:UIControlStateNormal];
    
    image = [UIImage imageNamed:@"ShutterButtonStop"];
    self.recStopImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.recBtn setTintColor:[UIColor colorWithRed:245./255.
                                              green:51./255.
                                               blue:51./255.
                                              alpha:1.0]];
    self.outerImage1 = [UIImage imageNamed:@"outer1"];
    self.outerImage2 = [UIImage imageNamed:@"outer2"];
    self.outerImageView.image = self.outerImage1;
}

- (void)viewDidLayoutSubviews {

    if (!self.captureManager) {
        self.captureManager = [[TTMCaptureManager alloc] initWithPreviewView:self.view
                                                         preferredCameraType:CameraTypeBack
                                                                  outputMode:OutputModeVideoData];
        self.captureManager.delegate = self;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// =============================================================================
#pragma mark - Gesture Handler

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {
    
    [self.captureManager toggleContentsGravity];
}


// =============================================================================
#pragma mark - Private


- (void)saveRecordedFile:(NSURL *)recordedFile {
    
    [SVProgressHUD showWithStatus:@"Saving..."
                         maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        [assetLibrary writeVideoAtPathToSavedPhotosAlbum:recordedFile
                                         completionBlock:
         ^(NSURL *assetURL, NSError *error) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [SVProgressHUD dismiss];
                 
                 NSString *title;
                 NSString *message;
                 
                 if (error != nil) {
                     
                     title = @"Failed to save video";
                     message = [error localizedDescription];
                 }
                 else {
                     title = @"Saved!";
                     message = nil;
                 }
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                 message:message
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
             });
         }];
    });
}



// =============================================================================
#pragma mark - Timer Handler

- (void)timerHandler:(NSTimer *)timer {
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval recorded = current - startTime;
    
    self.statusLabel.text = [NSString stringWithFormat:@"%.2f", recorded];
}



// =============================================================================
#pragma mark - AVCaptureManagerDeleagte

- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
    
    if (error) {
        NSLog(@"error:%@", error);
        return;
    }
    
    if (!isNeededToSave) {
        return;
    }
    
    [self saveRecordedFile:outputFileURL];
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)recButtonTapped:(id)sender {
    
    // REC START
    if (!self.captureManager.isRecording) {
        
        // change UI
        [self.recBtn setImage:self.recStopImage
                     forState:UIControlStateNormal];
        self.fpsControl.enabled = NO;
        
        // timer start
        startTime = [[NSDate date] timeIntervalSince1970];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(timerHandler:)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [self.captureManager startRecording];
    }
    // REC STOP
    else {
        
        isNeededToSave = YES;
        [self.captureManager stopRecording];
        
        [self.timer invalidate];
        self.timer = nil;
        
        // change UI
        [self.recBtn setImage:self.recStartImage
                     forState:UIControlStateNormal];
        self.fpsControl.enabled = YES;
    }
}

- (IBAction)fpsChanged:(UISegmentedControl *)sender {
    
    // Switch FPS
    
    CGFloat desiredFps = 0.0;;
    switch (self.fpsControl.selectedSegmentIndex) {
        case 0:
        default:
        {
            break;
        }
        case 1:
            desiredFps = 60.0;
            break;
        case 2:
            desiredFps = 240.0;
            break;
    }
    
    
    [SVProgressHUD showWithStatus:@"Switching..."
                         maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        if (desiredFps > 0.0) {
            [self.captureManager switchFormatWithDesiredFPS:desiredFps];
        }
        else {
            [self.captureManager resetFormat];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (desiredFps >= 120.0) {
                self.outerImageView.image = self.outerImage2;
            }
            else {
                self.outerImageView.image = self.outerImage1;
            }
            [SVProgressHUD dismiss];
        });
    });
}

@end
