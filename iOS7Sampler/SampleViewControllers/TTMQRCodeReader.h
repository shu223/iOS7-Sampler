//
//  TTMQRCodeReader.h
//  iOS7Sampler
//
//  Created by Shuichi Tsutsumi on 2015/04/08.
//  Copyright (c) 2015年 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AVMetadataMachineReadableCodeObject;

@protocol TTMQRCodeReaderDelegate <NSObject>
- (void)didDetectQRCode:(AVMetadataMachineReadableCodeObject *)qrCode;
@end


@interface TTMQRCodeReader : NSObject

@property (nonatomic, weak) id<TTMQRCodeReaderDelegate> delegate;

+ (instancetype)sharedReader;

- (void)startReaderOnView:(UIView *)view;
- (void)stopReader;

@end
