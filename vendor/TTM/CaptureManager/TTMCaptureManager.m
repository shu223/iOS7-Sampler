//
//  TTMCaptureManager.m
//  SlowMotionVideoRecorder
//  https://github.com/shu223/SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "TTMCaptureManager.h"
#import <AVFoundation/AVFoundation.h>


@interface TTMCaptureManager ()
<AVCaptureFileOutputRecordingDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CMTime defaultVideoMaxFrameDuration;
    BOOL readyToRecordAudio;
    BOOL readyToRecordVideo;
    AVCaptureVideoOrientation videoOrientation;
    AVCaptureVideoOrientation referenceOrientation;
    dispatch_queue_t movieWritingQueue;
    CMBufferQueueRef previewBufferQueue;
	BOOL recordingWillBeStarted;
    OutputMode currentOutputMode;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;

// for video data output
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@end


@implementation TTMCaptureManager

- (instancetype)initWithPreviewView:(UIView *)previewView
                preferredCameraType:(CameraType)cameraType
                         outputMode:(OutputMode)outputMode
{
    self = [super init];
    
    if (self) {
    
        currentOutputMode = outputMode;
        
        referenceOrientation = (AVCaptureVideoOrientation)UIDeviceOrientationPortrait;

        NSError *error;
        
        self.captureSession = [[AVCaptureSession alloc] init];
        self.captureSession.sessionPreset = AVCaptureSessionPresetInputPriority;
        
        self.videoDevice = cameraType == CameraTypeFront ? [TTMCaptureManager frontCaptureDevice] : [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
        
        if (error) {
            NSLog(@"Video input creation failed");
            return nil;
        }
        
        if (![self.captureSession canAddInput:videoIn]) {
            NSLog(@"Video input add-to-session failed");
            return nil;
        }
        [self.captureSession addInput:videoIn];
        
        
        // save the default format
        self.defaultFormat = self.videoDevice.activeFormat;
        defaultVideoMaxFrameDuration = self.videoDevice.activeVideoMaxFrameDuration;
        
        NSLog(@"videoDevice.activeFormat:%@", self.videoDevice.activeFormat);
        
        AVCaptureDevice *audioDevice= [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioIn = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        [self.captureSession addInput:audioIn];
        
        if (previewView) {
            self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
            self.previewLayer.frame = previewView.bounds;
            self.previewLayer.contentsGravity = kCAGravityResizeAspectFill;
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [previewView.layer insertSublayer:self.previewLayer atIndex:0];
        }

        switch (outputMode) {
            case OutputModeMovieFile:
            default:
            {
                self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
                [self.captureSession addOutput:self.movieFileOutput];
                break;
            }
            case OutputModeVideoData:
            {
                // Video
                AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
                [self.captureSession addOutput:videoDataOutput];
                
                [videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];

                movieWritingQueue = dispatch_queue_create("com.shu223.moviewriting", DISPATCH_QUEUE_SERIAL);
                dispatch_queue_t videoCaptureQueue = dispatch_queue_create("com.shu223.videocapture", NULL);
                [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
                [videoDataOutput setSampleBufferDelegate:self queue:videoCaptureQueue];

                self.videoConnection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
                videoOrientation = [self.videoConnection videoOrientation];

                // Audio
                AVCaptureAudioDataOutput *audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
                [self.captureSession addOutput:audioDataOutput];
                
                dispatch_queue_t audioCaptureQueue = dispatch_queue_create("com.shu223.audiocapture", DISPATCH_QUEUE_SERIAL);
                [audioDataOutput setSampleBufferDelegate:self queue:audioCaptureQueue];
                
                self.audioConnection = [audioDataOutput connectionWithMediaType:AVMediaTypeAudio];


                // BufferQueue
                OSStatus err = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
                NSLog(@"CMBufferQueueCreate error:%d", err);
                
                break;
            }
        }
        
        
        [self.captureSession startRunning];
    }
    return self;
}

+ (AVCaptureDevice *)frontCaptureDevice {
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            return device;
        }
    }

    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGFloat angle = 0.0;
	
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			angle = 0.0;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			angle = -M_PI_2;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			angle = M_PI_2;
			break;
		default:
			break;
	}
    
	return angle;
}

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	// Calculate offsets from an arbitrary reference orientation (portrait)
	CGFloat orientationAngleOffset = [TTMCaptureManager angleOffsetFromPortraitOrientationToOrientation:orientation];
	CGFloat videoOrientationAngleOffset = [TTMCaptureManager angleOffsetFromPortraitOrientationToOrientation:videoOrientation];
	
	// Find the difference in angle between the passed in orientation and the current video orientation
	CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
	transform = CGAffineTransformMakeRotation(angleOffset);
	
	return transform;
}

- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription
{
    float bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    int numPixels = dimensions.width * dimensions.height;
    int bitsPerSecond;
    
    // Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
    if ( numPixels < (640 * 480) )
        bitsPerPixel = 4.05; // This bitrate matches the quality produced by AVCaptureSessionPresetMedium or Low.
    else
        bitsPerPixel = 11.4; // This bitrate matches the quality produced by AVCaptureSessionPresetHigh.
    
    bitsPerSecond = numPixels * bitsPerPixel;
    
    NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              [NSNumber numberWithInteger:dimensions.width], AVVideoWidthKey,
                                              [NSNumber numberWithInteger:dimensions.height], AVVideoHeightKey,
                                              [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithInteger:bitsPerSecond], AVVideoAverageBitRateKey,
                                               [NSNumber numberWithInteger:30], AVVideoMaxKeyFrameIntervalKey,
                                               nil], AVVideoCompressionPropertiesKey,
                                              nil];
    
    NSLog(@"videoCompressionSetting:%@", videoCompressionSettings);
    
    if ([self.assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
        
        self.assetWriterVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                    outputSettings:videoCompressionSettings];
        
        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        self.assetWriterVideoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:referenceOrientation];
        
        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
            
            [self.assetWriter addInput:self.assetWriterVideoInput];
        }
        else {
            
            NSLog(@"Couldn't add asset writer video input.");
            return NO;
        }
    }
    else {
        
        NSLog(@"Couldn't apply video output settings.");
        return NO;
    }
    
    return YES;
}

- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription
{
	const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    
	size_t aclSize = 0;
	const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
	NSData *currentChannelLayoutData = nil;
	
	// AVChannelLayoutKey must be specified, but if we don't know any better give an empty data and let AVAssetWriter decide.
	if ( currentChannelLayout && aclSize > 0 ) {
        
		currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
    }
	else {
        
		currentChannelLayoutData = [NSData data];
    }
    
	NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
											  [NSNumber numberWithFloat:currentASBD->mSampleRate], AVSampleRateKey,
											  [NSNumber numberWithInt:64000], AVEncoderBitRatePerChannelKey,
											  [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame], AVNumberOfChannelsKey,
											  currentChannelLayoutData, AVChannelLayoutKey,
											  nil];
	if ([self.assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
        
		self.assetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                                                    outputSettings:audioCompressionSettings];
        
		self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
		if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
            
			[self.assetWriter addInput:self.assetWriterAudioInput];
        }
		else {
            
			NSLog(@"Couldn't add asset writer audio input.");
            return NO;
		}
	}
	else {
        
		NSLog(@"Couldn't apply audio output settings.");
        return NO;
	}
    
    return YES;
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer
                   ofType:(NSString *)mediaType
{
    if (self.assetWriter.status == AVAssetWriterStatusUnknown) {
        
        if ([self.assetWriter startWriting]) {
            
            CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [self.assetWriter startSessionAtSourceTime:timestamp];
        }
        else {
            
            NSLog(@"AVAssetWriter startWriting error:%@", self.assetWriter.error);
        }
    }
    
    if (self.assetWriter.status == AVAssetWriterStatusWriting) {
        
        if (mediaType == AVMediaTypeVideo) {
            
            if (self.assetWriterVideoInput.readyForMoreMediaData) {
                
                if (![self.assetWriterVideoInput appendSampleBuffer:sampleBuffer]) {
                    
                    NSLog(@"isRecording:%d, willBeStarted:%d", self.isRecording, recordingWillBeStarted);
                    NSLog(@"AVAssetWriterInput video appendSapleBuffer error:%@", self.assetWriter.error);
                }
            }
        }
        else if (mediaType == AVMediaTypeAudio) {
            
            if (self.assetWriterAudioInput.readyForMoreMediaData) {
                
                if (![self.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                    
                    NSLog(@"AVAssetWriterInput audio appendSapleBuffer error:%@", self.assetWriter.error);
                }
            }
        }
    }
}


// =============================================================================
#pragma mark - Public

- (void)toggleContentsGravity {
    
    if ([self.previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
    
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    else {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

- (void)resetFormat {

    BOOL isRunning = self.captureSession.isRunning;
    
    if (isRunning) {
        [self.captureSession stopRunning];
    }

    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [videoDevice lockForConfiguration:nil];
    videoDevice.activeFormat = self.defaultFormat;
    videoDevice.activeVideoMaxFrameDuration = defaultVideoMaxFrameDuration;
    [videoDevice unlockForConfiguration];

    if (isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS
{
    BOOL isRunning = self.captureSession.isRunning;
    
    if (isRunning)  [self.captureSession stopRunning];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;

    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;

            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    
    if (selectedFormat) {
        
        if ([videoDevice lockForConfiguration:nil]) {
            
            NSLog(@"selected format:%@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
    
    if (isRunning) [self.captureSession startRunning];
}

- (void)startRecording {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString* dateTimePrefix = [formatter stringFromDate:[NSDate date]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if (currentOutputMode == OutputModeMovieFile) {
        
        int fileNamePostfix = 0;
        NSString *filePath = nil;

        do
            filePath =[NSString stringWithFormat:@"/%@/%@-%i.mp4", documentsDirectory, dateTimePrefix, fileNamePostfix++];
        while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
        
        self.fileURL = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];

        [self.movieFileOutput startRecordingToOutputFileURL:self.fileURL recordingDelegate:self];
    }
    else if (currentOutputMode == OutputModeVideoData) {

        dispatch_async(movieWritingQueue, ^{

            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
            // Don't update the reference orientation when the device orientation is face up/down or unknown.
            if (UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation)) {
                referenceOrientation = (AVCaptureVideoOrientation)orientation;
            }

            int fileNamePostfix = 0;
            NSString *filePath = nil;

            do
                filePath =[NSString stringWithFormat:@"/%@/%@-%i.MOV", documentsDirectory, dateTimePrefix, fileNamePostfix++];
            while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            self.fileURL = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];

            NSError *error;
            self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.fileURL
                                                         fileType:AVFileTypeQuickTimeMovie
                                                            error:&error];
            NSLog(@"AVAssetWriter error:%@", error);
            
            recordingWillBeStarted = YES;
            
            //        [self.assetWriter startWriting];
            //        [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
        });
    }
}

- (void)stopRecording {

    if (currentOutputMode == OutputModeMovieFile) {
        
        [self.movieFileOutput stopRecording];
    }
    else if (currentOutputMode == OutputModeVideoData) {
        
        dispatch_async(movieWritingQueue, ^{

            _isRecording = NO;
			readyToRecordVideo = NO;
			readyToRecordAudio = NO;

            [self.assetWriter finishWritingWithCompletionHandler:^{
                
                self.assetWriterVideoInput = nil;
                self.assetWriterAudioInput = nil;
                self.assetWriter = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([self.delegate respondsToSelector:@selector(didFinishRecordingToOutputFileAtURL:error:)]) {
                        [self.delegate didFinishRecordingToOutputFileAtURL:self.fileURL error:nil];
                    }
                });
            }];
        });
    }
}

- (void)updateOrientationWithPreviewView:(UIView *)previewView {

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    // Don't update the reference orientation when the device orientation is face up/down or unknown.
    if (UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation)) {
        referenceOrientation = (AVCaptureVideoOrientation)orientation;
    }

    self.previewLayer.frame = previewView.bounds;

    [[self.previewLayer connection] setVideoOrientation:self.videoConnection.videoOrientation];

    readyToRecordVideo = NO;
}



// =============================================================================
#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)                 captureOutput:(AVCaptureFileOutput *)captureOutput
    didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                       fromConnections:(NSArray *)connections
{
    _isRecording = YES;
}

- (void)                 captureOutput:(AVCaptureFileOutput *)captureOutput
   didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                       fromConnections:(NSArray *)connections error:(NSError *)error
{
//    [self saveRecordedFile:outputFileURL];
    _isRecording = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFinishRecordingToOutputFileAtURL:error:)]) {
        [self.delegate didFinishRecordingToOutputFileAtURL:outputFileURL error:error];
    }
}


// =============================================================================
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)    captureOutput:(AVCaptureOutput *)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection
{
    if (self.onBuffer) {
        self.onBuffer(sampleBuffer);
    }
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);

    CFRetain(sampleBuffer);

    dispatch_async(movieWritingQueue, ^{
        
        if (self.assetWriter && (self.isRecording || recordingWillBeStarted)) {
            
            BOOL wasReadyToRecord = (readyToRecordAudio && readyToRecordVideo);
            
            if (connection == self.videoConnection) {
                
                // Initialize the video input if this is not done yet
                if (!readyToRecordVideo) {
                    
                    readyToRecordVideo = [self setupAssetWriterVideoInput:formatDescription];
                }
                
                // Write video data to file
                if (readyToRecordVideo && readyToRecordAudio) {
                    [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                }
            }
            else if (connection == self.audioConnection) {
                
                // Initialize the audio input if this is not done yet
                if (!readyToRecordAudio) {
                    readyToRecordAudio = [self setupAssetWriterAudioInput:formatDescription];
                }
                
                // Write audio data to file
                if (readyToRecordAudio && readyToRecordVideo)
                    [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
            }
                        
            BOOL isReadyToRecord = (readyToRecordAudio && readyToRecordVideo);
            if (!wasReadyToRecord && isReadyToRecord) {
                
                recordingWillBeStarted = NO;
                _isRecording = YES;
            }
        }
		CFRelease(sampleBuffer);
    });
}

@end
