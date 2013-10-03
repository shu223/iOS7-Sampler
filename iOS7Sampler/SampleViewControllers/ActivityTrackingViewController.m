//
//  ActivityTrackingViewController.m
//  iOS7Sampler
//
//  Created by shuichi on 10/2/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "ActivityTrackingViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "SVProgressHUD.h"


@interface ActivityTrackingViewController ()
@property (nonatomic, strong) CMStepCounter *stepCounter;
@property (nonatomic, strong) CMMotionActivityManager *activityManager;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, weak) IBOutlet UILabel *stepsLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *confidenceLabel;
@end


@implementation ActivityTrackingViewController

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
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self startTracking];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];


    [self.stepCounter stopStepCountingUpdates];

    [self.activityManager stopActivityUpdates];
    
    [self.operationQueue cancelAllOperations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


// =============================================================================
#pragma mark - Private

- (void)startTracking {
    
    if (!([CMStepCounter isStepCountingAvailable] || [CMMotionActivityManager isActivityAvailable])) {
        
        NSString *msg = @"CMStepCounter and CMMotionActivityManager are not available. These classes need M7 coprocessor, so this sample works only on iPhone5s.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Supported"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }

    __weak ActivityTrackingViewController *weakSelf = self;
    
    self.operationQueue = [[NSOperationQueue alloc] init];

    // Start step counting updates
    if ([CMStepCounter isStepCountingAvailable]) {
        
        self.stepCounter = [[CMStepCounter alloc] init];
    
        [self.stepCounter startStepCountingUpdatesToQueue:self.operationQueue
                                                 updateOn:1
                                              withHandler:
         ^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {

             dispatch_async(dispatch_get_main_queue(), ^{

                 if (error) {
                     
                     [SVProgressHUD showErrorWithStatus:error.description];
                 }
                 else {

                     NSString *text = [NSString stringWithFormat:@"Steps: %ld", (long)numberOfSteps];
                     
                     weakSelf.stepsLabel.text = text;
                 }
             });
         }];
    }
    
    // Start motion activity updates
    if ([CMMotionActivityManager isActivityAvailable]) {
        
        self.activityManager = [[CMMotionActivityManager alloc] init];

        [self.activityManager startActivityUpdatesToQueue:self.operationQueue
                                              withHandler:
         ^(CMMotionActivity *activity) {

             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 NSString *status = [weakSelf statusForActivity:activity];
                 NSString *confidence = [weakSelf stringFromConfidence:activity.confidence];
                 
                 weakSelf.statusLabel.text = [NSString stringWithFormat:@"Status: %@", status];
                 weakSelf.confidenceLabel.text = [NSString stringWithFormat:@"Confidence: %@", confidence];
             });
         }];
    }
}

- (NSString *)statusForActivity:(CMMotionActivity *)activity {

    NSMutableString *status = @"".mutableCopy;
    
    if (activity.stationary) {
        
        [status appendString:@"not moving"];
    }
    
    if (activity.walking) {

        if (status.length) [status appendString:@", "];

        [status appendString:@"on a walking person"];
    }
    
    if (activity.running) {

        if (status.length) [status appendString:@", "];
        
        [status appendString:@"on a running person"];
    }
    
    if (activity.automotive) {
        
        if (status.length) [status appendString:@", "];

        [status appendString:@"in a vehicle"];
    }
    
    if (activity.unknown || !status.length) {

        [status appendString:@"unknown"];
    }
    
    return status;
}

- (NSString *)stringFromConfidence:(CMMotionActivityConfidence)confidence {

    switch (confidence) {
            
        case CMMotionActivityConfidenceLow:

            return @"Low";

        case CMMotionActivityConfidenceMedium:
        
            return @"Medium";

        case CMMotionActivityConfidenceHigh:

            return @"High";
            
        default:

            return nil;
    }
}


// =============================================================================
#pragma mark - IBAction


@end
