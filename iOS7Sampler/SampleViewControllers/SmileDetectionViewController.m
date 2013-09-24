//
//  SmileDetectionViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 9/25/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "SmileDetectionViewController.h"
#import  "SVProgressHUD.h"


@interface SmileDetectionViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end


@implementation SmileDetectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [SVProgressHUD showWithStatus:@"Processing..."
                         maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        CIImage *image = [CIImage imageWithCGImage:self.imageView.image.CGImage];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        
        NSDictionary *options = @{
                                  CIDetectorSmile: @(YES),
                                  CIDetectorEyeBlink: @(YES),
                                  };
        
        NSArray *features = [detector featuresInImage:image options:options];
        
        NSMutableString *resultStr = @"DETECTED FACES:\n\n".mutableCopy;
        
        for(CIFaceFeature *feature in features)
        {
            [resultStr appendFormat:@"bounds:%@\n", NSStringFromCGRect(feature.bounds)];
            [resultStr appendFormat:@"hasSmile: %@\n\n", feature.hasSmile ? @"YES" : @"NO"];
            //        NSLog(@"faceAngle: %@", feature.hasFaceAngle ? @(feature.faceAngle) : @"NONE");
            //        NSLog(@"leftEyeClosed: %@", feature.leftEyeClosed ? @"YES" : @"NO");
            //        NSLog(@"rightEyeClosed: %@", feature.rightEyeClosed ? @"YES" : @"NO");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [SVProgressHUD dismiss];
            
            self.textView.text = resultStr;
        });
    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
