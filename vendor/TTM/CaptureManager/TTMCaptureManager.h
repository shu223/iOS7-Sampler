//
//  TTMCaptureManager.h
//  SlowMotionVideoRecorder
//  https://github.com/shu223/SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreMedia;


typedef NS_ENUM(NSUInteger, CameraType) {
    CameraTypeBack,
    CameraTypeFront,
};

typedef NS_ENUM(NSUInteger, OutputMode) {
    OutputModeVideoData,
    OutputModeMovieFile,
};


@protocol TTMCaptureManagerDelegate <NSObject>
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                      error:(NSError *)error;
@end


@interface TTMCaptureManager : NSObject

@property (nonatomic, assign) id<TTMCaptureManagerDelegate> delegate;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, copy) void (^onBuffer)(CMSampleBufferRef sampleBuffer);

- (instancetype)initWithPreviewView:(UIView *)previewView
                preferredCameraType:(CameraType)cameraType
                         outputMode:(OutputMode)outputMode;
- (void)toggleContentsGravity;
- (void)resetFormat;
- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS;
- (void)startRecording;
- (void)stopRecording;
- (void)updateOrientationWithPreviewView:(UIView *)previewView;

@end
